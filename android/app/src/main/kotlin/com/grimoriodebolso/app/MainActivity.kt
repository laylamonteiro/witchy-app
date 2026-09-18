package com.grimoriodebolso.app

import android.util.Log
import com.google.android.play.core.review.ReviewException
import com.google.android.play.core.review.ReviewManagerFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicBoolean

/**
 * O card nativo de avaliação do Google, exposto ao Dart por um canal próprio.
 *
 * Por que canal próprio e não um pacote pronto: a suíte de testes deste repo
 * resolve as dependências do cache, offline, e uma dependência Dart nova a
 * derrubaria inteira. Deste lado o custo é uma linha de Gradle.
 *
 * O contrato é um número só, e ele diz O QUE ACONTECEU — não se a pessoa
 * gostou. A API do Play não conta isso a ninguém: "The API does not indicate
 * whether the user reviewed or not, or even whether the review dialog was
 * shown". Quem interpreta os códigos é o lado Dart; aqui eles só são
 * produzidos com honestidade.
 *
 * A diferença entre [LANCADO] e [ADIAR] é o que impede o app de queimar em
 * silêncio as poucas chances que tem: um tiro com a tela indo embora não
 * mostra nada, e não pode ser contado como convite feito.
 */
class MainActivity : FlutterActivity() {

    private var canalDeAvaliacao: MethodChannel? = null

    /**
     * Um fluxo de avaliação por vez. Dois `launchReviewFlow` em voo gastam
     * cota dobrada, e o Play não documenta o que faz nesse caso.
     *
     * Se um listener do Play nunca voltar, isto fica travado e todo pedido
     * seguinte responde [ADIAR] — nada é mostrado e nada é carimbado. É o
     * resultado certo para uma Play pendurada, e ele dura só até a Activity ser
     * recriada, porque o estado é dela.
     */
    private val emVoo = AtomicBoolean(false)

    /**
     * O app está à FRENTE?
     *
     * Vem dos callbacks do ciclo de vida em vez de `androidx.lifecycle`, que
     * chega aqui por transitividade do embedding do Flutter — depender dela no
     * classpath de compilação seria apostar num detalhe de empacotamento que
     * não é nosso. Dois overrides resolvem sem importar nada.
     */
    @Volatile
    private var naFrente = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        canalDeAvaliacao = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CANAL_DE_AVALIACAO,
        ).apply {
            setMethodCallHandler { chamada, resultado ->
                atender(chamada, RespostaUnica(resultado))
            }
        }
    }

    override fun onResume() {
        super.onResume()
        naFrente = true
    }

    override fun onPause() {
        naFrente = false
        super.onPause()
    }

    override fun onDestroy() {
        // Fecha a porta para chamadas NOVAS. A resposta de uma chamada que já
        // está em voo não passa por aqui: ela é protegida pelo AtomicBoolean
        // da RespostaUnica, e se chegar depois do engine morrer o lado Flutter
        // apenas registra um aviso. Não é o onDestroy que resolve aquele caso.
        canalDeAvaliacao?.setMethodCallHandler(null)
        canalDeAvaliacao = null
        super.onDestroy()
    }

    private fun atender(chamada: MethodCall, resposta: RespostaUnica) {
        when (chamada.method) {
            METODO_PEDIR_AVALIACAO -> pedirAvaliacao(resposta)
            else -> resposta.naoImplementado()
        }
    }

    /**
     * Pede o card ao Play.
     *
     * O corpo INTEIRO vive dentro de um `catch (Throwable)` de propósito. O
     * handler de canal do Flutter só embrulha `RuntimeException`; um
     * `NoClassDefFoundError` — o que um R8 sem keep rule produz — escaparia
     * dali, subiria pela thread de UI e DERRUBARIA O APP. O convite não pode
     * derrubar a tela em que ele apareceria.
     */
    private fun pedirAvaliacao(resposta: RespostaUnica) {
        try {
            if (!podeAbrirAgora()) {
                resposta.entregar(ADIAR)
                return
            }
            if (!emVoo.compareAndSet(false, true)) {
                Log.w(TAG, "a review flow was already in flight")
                resposta.entregar(ADIAR)
                return
            }

            val gerente = ReviewManagerFactory.create(applicationContext)

            // O ReviewInfo vale pouco tempo, então pedido e disparo andam
            // colados — nada de guardar isto para usar minutos depois.
            gerente.requestReviewFlow().addOnCompleteListener { pedido ->
                try {
                    if (!pedido.isSuccessful) {
                        val erro = pedido.exception
                        val codigo = (erro as? ReviewException)?.errorCode ?: ERRO_INTERNO
                        Log.w(TAG, "review flow unavailable (errorCode=$codigo): $erro")
                        soltar(resposta, codigo)
                        return@addOnCompleteListener
                    }
                    if (!podeAbrirAgora()) {
                        soltar(resposta, ADIAR)
                        return@addOnCompleteListener
                    }

                    gerente.launchReviewFlow(this@MainActivity, pedido.result)
                        .addOnCompleteListener { fluxo ->
                            // Só para o log: o resultado não distingue "o card
                            // apareceu" de "a cota engoliu".
                            Log.i(TAG, "review flow finished (ok=${fluxo.isSuccessful})")
                            emVoo.set(false)
                        }

                    // A resposta sai AQUI, no lançamento — não na conclusão.
                    // Se ela esperasse o card fechar, uma morte de processo com
                    // o card aberto deixaria os carimbos por gravar, e o app
                    // dispararia de novo no rito seguinte, em rajada, contra a
                    // cota silenciosa do Google.
                    resposta.entregar(LANCADO)
                } catch (e: Throwable) {
                    Log.w(TAG, "could not launch the review flow: $e")
                    soltar(resposta, ERRO_INTERNO)
                }
            }
        } catch (e: Throwable) {
            Log.w(TAG, "could not ask for a review: $e")
            soltar(resposta, ERRO_INTERNO)
        }
    }

    /** Há tela viva e à frente para o card subir? */
    private fun podeAbrirAgora(): Boolean {
        if (isFinishing || isDestroyed) return false
        // Uma Activity apenas pausada não mostra o card — e o tiro perdido
        // custaria uma das poucas chances que esta pessoa tem.
        return naFrente
    }

    private fun soltar(resposta: RespostaUnica, codigo: Int) {
        emVoo.set(false)
        resposta.entregar(codigo)
    }

    /**
     * O `result` do canal aceita UMA resposta só — a segunda derruba o app com
     * IllegalStateException. Como há vários caminhos de saída, todos passam por
     * aqui e só o primeiro vale.
     *
     * A volta é sempre na thread da UI: o canal do Flutter exige isso, e os
     * listeners do Play não prometem em qual thread chamam. `runOnUiThread`
     * executa na hora quando já se está nela, então não custa nada.
     */
    private inner class RespostaUnica(private val resultado: MethodChannel.Result) {
        private val jaRespondeu = AtomicBoolean(false)

        fun entregar(codigo: Int) {
            if (!jaRespondeu.compareAndSet(false, true)) return
            runOnUiThread { resultado.success(codigo) }
        }

        fun naoImplementado() {
            if (!jaRespondeu.compareAndSet(false, true)) return
            runOnUiThread { resultado.notImplemented() }
        }
    }

    private companion object {
        const val CANAL_DE_AVALIACAO = "com.grimoriodebolso.app/avaliacao"
        const val METODO_PEDIR_AVALIACAO = "pedirAvaliacao"
        const val TAG = "Avaliacao"

        /** O fluxo foi lançado. Não quer dizer que a pessoa viu, nem avaliou. */
        const val LANCADO = 0

        /** Não é hora: tela indo embora, app em segundo plano, fluxo em voo. */
        const val ADIAR = -1000

        /** Falha do Play que não tem código próprio (INTERNAL_ERROR). */
        const val ERRO_INTERNO = -100
    }
}
