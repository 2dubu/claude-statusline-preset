// ccstatusline custom-command 위젯용 — 모델명 + 1M 컨텍스트 태그.
// 내장 Model 위젯은 display_name 끝의 "(...)"를 잘라내 "(1M context)"가 사라진다.
// 이 스크립트는 그 대신 base 모델명에 1M 세션이면 " (1M)"을 붙여 "Model: Opus 4.8 (1M)"로 렌더.
// status JSON 을 stdin 으로 받음(ccstatusline custom-command 규약).
let s = ''
process.stdin.on('data', (d) => (s += d)).on('end', () => {
  let out = ''
  try {
    const m = JSON.parse(s).model || {}
    const dn = m.display_name || m.id || ''
    const base = dn.replace(/\s*\(.*\)$/, '') // "Opus 4.8 (1M context)" → "Opus 4.8"
    const is1m = /\[1m\]/i.test(m.id || '') || /\(1m context\)/i.test(dn)
    if (base) out = base + (is1m ? ' (1M)' : '')
  } catch {
    /* JSON 파싱 실패 시 빈 출력 */
  }
  process.stdout.write(out)
})
