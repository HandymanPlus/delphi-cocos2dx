'															'+#$D#$A+		
'#ifdef GL_ES												'+#$D#$A+		
'attribute mediump vec4 a_position;							'+#$D#$A+		
'attribute mediump vec2 a_texcoord;							'+#$D#$A+		
'attribute mediump vec4 a_color;							'+#$D#$A+		
'															'+#$D#$A+	
'varying mediump vec4 v_color;								'+#$D#$A+		
'varying mediump vec2 v_texcoord;							'+#$D#$A+		
'															'+#$D#$A+		
'#else														'+#$D#$A+		
'attribute vec4 a_position;									'+#$D#$A+		
'attribute vec2 a_texcoord;									'+#$D#$A+		
'attribute vec4 a_color;									'+#$D#$A+			
'															'+#$D#$A+		
'varying vec4 v_color;										'+#$D#$A+	
'varying vec2 v_texcoord;									'+#$D#$A+		
'#endif														'+#$D#$A+	
'															'+#$D#$A+		
'void main()												'+#$D#$A+			
'{															'+#$D#$A+		
'	v_color = vec4(a_color.rgb * a_color.a, a_color.a);		'+#$D#$A+		
'	v_texcoord = a_texcoord;								'+#$D#$A+	
'															'+#$D#$A+	
'	gl_Position = CC_MVPMatrix * a_position;				'+#$D#$A+		
'}															'	
;
