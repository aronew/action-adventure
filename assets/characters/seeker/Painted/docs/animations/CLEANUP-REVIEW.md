# Cleanup review

Pass completed: all unique source and painted poses were compared in contact sheets. Frames repeated in the source reuse their corresponding reviewed pose.

The strongest visible corrections are in Attack2, HeavyAttack, HeavyAttack FX and the blink/fade frames. Shared source poses across Hurt/HurtKnockback, jump states, standing states and crouch/grapple now reuse the same painted artwork at their original offsets.

Verified export checks: 22 animations / 252 character frames; 17 split sheets / 136 split cells; 322 processed layer slots; 29 empty FX slots; 66 main-frame Body/FX compositions; original timing arrays; scaled pivots; no artwork outside reference registration rectangles; matching death-frame maximum opacity.

Still approximate: internal pose silhouettes and anatomical landmarks. Not certified: pixel-exact eyes, grips, sword tips or engine integration. Source split-pair exceptions: Attack1:3, HeavyAttack:4, HeavyAttack:5. Inspect the source ghost overlay and the audit for these distinctions.

## Third pass

Rechecked all 322 layer slots. Fixed the four overbright later grapple pulses and six over-dark doorway fade frames. All 252 body alpha silhouettes are byte-identical to v2, so these fixes did not move or reshape the character. The other 312 layer slots are unchanged. All FX active-frame patterns match their originals. The export checks pass; internal pose equivalence and in-engine smoothness remain uncertified. See Pass3-Changes.json and the third_pass section in Validation.json.
