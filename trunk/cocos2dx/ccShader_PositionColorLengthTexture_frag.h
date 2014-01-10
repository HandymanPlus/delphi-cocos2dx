'																										'+#$D#$A+					
'#ifdef GL_ES																							'+#$D#$A+					
'// #extension GL_OES_standard_derivatives : enable														'+#$D#$A+				
'																										'+#$D#$A+				
'varying mediump vec4 v_color;																			'+#$D#$A+				
'varying mediump vec2 v_texcoord;																		'+#$D#$A+				
'#else																									'+#$D#$A+				
'varying vec4 v_color;																					'+#$D#$A+				
'varying vec2 v_texcoord;																				'+#$D#$A+		
'#endif																									'+#$D#$A+				
'																										'+#$D#$A+				
'void main()																							'+#$D#$A+					
'{																										'+#$D#$A+				
'// #if defined GL_OES_standard_derivatives																'+#$D#$A+						
'	// gl_FragColor = v_color*smoothstep(0.0, length(fwidth(v_texcoord)), 1.0 - length(v_texcoord));	'+#$D#$A+					
'// #else																								'+#$D#$A+						
'	gl_FragColor = v_color*step(0.0, 1.0 - length(v_texcoord));											'+#$D#$A+					
'// #endif																								'+#$D#$A+					
'}																										'					
;
