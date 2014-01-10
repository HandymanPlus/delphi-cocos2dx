'                                                             '+#$D#$A+
'#ifdef GL_ES                                                 '+#$D#$A+
'precision lowp float;                                        '+#$D#$A+
'#endif                                                       '+#$D#$A+
'                                                             '+#$D#$A+
'varying vec4 v_fragmentColor;                                '+#$D#$A+
'varying vec2 v_texCoord;                                     '+#$D#$A+
'uniform sampler2D CC_Texture0;                               '+#$D#$A+
'uniform        float CC_alpha_value;                         '+#$D#$A+
'                                                             '+#$D#$A+
'void main()                                                  '+#$D#$A+
'{                                                            '+#$D#$A+
'    vec4 texColor = texture2D(CC_Texture0, v_texCoord);      '+#$D#$A+
'                                                             '+#$D#$A+
'    // mimic: glAlphaFunc(GL_GREATER)                        '+#$D#$A+
'    // pass if ( incoming_pixel >= CC_alpha_value ) => fail if incoming_pixel < CC_alpha_value  '+#$D#$A+
'                                                             '+#$D#$A+
'    if ( texColor.a <= CC_alpha_value )                       '+#$D#$A+
'        discard;                                             '+#$D#$A+
'                                                             '+#$D#$A+
'    gl_FragColor = texColor * v_fragmentColor;               '+#$D#$A+
'}                                                            '
;
