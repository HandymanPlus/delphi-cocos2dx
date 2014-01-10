'                                                '+#$D#$A+
'#ifdef GL_ES                                    '+#$D#$A+
'precision lowp float;                           '+#$D#$A+
'#endif                                          '+#$D#$A+
'                                                '+#$D#$A+
'varying vec4        v_fragmentColor;            '+#$D#$A+
'varying vec2        v_texCoord;                 '+#$D#$A+
'uniform sampler2D   u_texture;                  '+#$D#$A+
'uniform sampler2D   u_mask;                     '+#$D#$A+
'                                                '+#$D#$A+
'void main()                                     '+#$D#$A+
'{                                               '+#$D#$A+
'    vec4 texColor   = texture2D(u_texture, v_texCoord);                                      '+#$D#$A+
'    vec4 maskColor  = texture2D(u_mask, v_texCoord);                                         '+#$D#$A+
'    vec4 finalColor = vec4(texColor.r, texColor.g, texColor.b, maskColor.a * texColor.a);    '+#$D#$A+
'    gl_FragColor    = v_fragmentColor * finalColor;                                          '+#$D#$A+
'}                                                                                            '
;
