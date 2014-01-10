'                                                        '+#$D#$A+
'attribute vec4 a_position;                              '+#$D#$A+
'attribute vec4 a_color;                                 '+#$D#$A+
'#ifdef GL_ES                                            '+#$D#$A+
'varying lowp vec4 v_fragmentColor;                      '+#$D#$A+
'#else                                                   '+#$D#$A+
'varying vec4 v_fragmentColor;                           '+#$D#$A+
'#endif                                                  '+#$D#$A+
'                                                        '+#$D#$A+
'void main()                                             '+#$D#$A+
'{                                                       '+#$D#$A+
'    gl_Position = CC_MVPMatrix * a_position;             '+#$D#$A+
'    v_fragmentColor = a_color;                          '+#$D#$A+
'}                                                       '
;
