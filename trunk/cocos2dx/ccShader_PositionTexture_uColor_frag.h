'                                       						     '+#$D#$A+
'#ifdef GL_ES                            							 '+#$D#$A+
'precision lowp float;                      		 				 '+#$D#$A+
'#endif                                  							 '+#$D#$A+
'                                        							 '+#$D#$A+
'uniform        vec4 u_color;            							 '+#$D#$A+
'                                        							 '+#$D#$A+
'varying vec2 v_texCoord;                							 '+#$D#$A+
'                                      								 '+#$D#$A+
'uniform sampler2D CC_Texture0;            							 '+#$D#$A+
'                                     								 '+#$D#$A+
'void main()                            							 '+#$D#$A+
'{                                      							 '+#$D#$A+
'    gl_FragColor =  texture2D(CC_Texture0, v_texCoord) * u_color;   '+#$D#$A+
'}                                        							 '
;