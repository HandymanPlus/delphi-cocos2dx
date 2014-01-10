'                                   				'+#$D#$A+
'attribute vec4 a_position;         				'+#$D#$A+
'attribute vec2 a_texCoord;         				'+#$D#$A+
'                                   				'+#$D#$A+
'#ifdef GL_ES                       				'+#$D#$A+
'varying mediump vec2 v_texCoord;   				'+#$D#$A+
'#else                              				'+#$D#$A+
'varying vec2 v_texCoord;           				'+#$D#$A+
'#endif                             				'+#$D#$A+
'                                   				'+#$D#$A+
'void main()                        				'+#$D#$A+
'{                                  				'+#$D#$A+
'    gl_Position = CC_MVPMatrix * a_position;       '+#$D#$A+
'    v_texCoord = a_texCoord;       				'+#$D#$A+
'}                                  				'
;
