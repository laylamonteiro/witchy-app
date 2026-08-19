#!/usr/bin/env python3
"""Gera web/termos/index.html a partir de assets/legal/termos_de_uso.md.

Os termos que o app exibe e os que o site publica precisam ser o MESMO texto:
editar o markdown e rodar este script mantém os dois em dia.

    python3 tools/gerar_termos_web.py
"""
import html as htmllib
import os
import re

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MD = os.path.join(RAIZ, 'assets/legal/termos_de_uso.md')
MODELO = os.path.join(RAIZ, 'docs/privacy-policy.html')  # só o <head>/CSS
SAIDA = os.path.join(RAIZ, 'web/termos/index.html')
EMAIL = 'suporte.grimoriodebolso@gmail.com'
INTRO = 'Bem-vinda(o) ao Grimório de Bolso'


def inline(texto):
    saida = htmllib.escape(texto, quote=False)
    saida = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', saida)
    return saida.replace(EMAIL, f'<a href="mailto:{EMAIL}">{EMAIL}</a>')


def main():
    cabecalho = open(MODELO, encoding='utf-8').read().split('</head>')[0] + '</head>'
    cabecalho = re.sub(r'<title>.*?</title>',
                       '<title>Termos de Uso — Grimório de Bolso</title>',
                       cabecalho, flags=re.S)

    corpo, lista = [], []

    def fechar_lista():
        if lista:
            corpo.append('            <ul>')
            corpo.extend(f'                <li>{i}</li>' for i in lista)
            corpo.append('            </ul>')
            lista.clear()

    for bruta in open(MD, encoding='utf-8').read().splitlines():
        linha = bruta.strip()
        if not linha:
            fechar_lista()
        elif linha.startswith('# ') or linha.startswith('Última atualização'):
            continue  # já vêm no cabeçalho fixo
        elif linha.startswith(INTRO):
            continue  # idem
        elif linha.startswith('## '):
            fechar_lista()
            corpo.append(f'            <h2>{inline(linha[3:])}</h2>')
        elif linha.startswith('- '):
            lista.append(inline(linha[2:]))
        else:
            fechar_lista()
            corpo.append(f'            <p>{inline(linha)}</p>')
    fechar_lista()

    pagina = f'''{cabecalho}
<body>
    <div class="container">
        <div class="brand">🌙</div>
        <h1>Termos de Uso</h1>
        <p class="last-updated">Grimório de Bolso &bull; Última atualização: 19 de julho de 2026</p>

        <p>Bem-vinda(o) ao <strong>Grimório de Bolso</strong>. Ao usar o aplicativo, você concorda com estes Termos. Leia com atenção.</p>

{chr(10).join(corpo)}

            <h2>Documentos relacionados</h2>
            <ul>
                <li>🔒 <a href="/privacidade/">Política de Privacidade</a></li>
                <li>✦ <a href="/sobre/">Sobre o Grimório de Bolso</a></li>
            </ul>
        </div>

        <div class="footer">
            <p>Grimório de Bolso © 2026 &bull; Feito com magia e código 🌙✨</p>
        </div>
    </div>
</body>
</html>
'''
    os.makedirs(os.path.dirname(SAIDA), exist_ok=True)
    open(SAIDA, 'w', encoding='utf-8').write(pagina)
    print(f'gerado: {SAIDA} ({len(pagina)} bytes)')


if __name__ == '__main__':
    main()
