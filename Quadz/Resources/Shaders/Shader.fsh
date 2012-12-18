//
//  Shader.fsh
//  Quadz
//
//  Created by Dirk Zimmermann on 10/26/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

precision mediump float;

uniform sampler2D s_texture0;
varying vec4 v_color;
varying vec4 v_backgroundColor;
varying vec2 v_texCoord0;

void main()
{
    vec4 textureColor = texture2D(s_texture0, v_texCoord0);
    float alpha = textureColor.r; // texels are grey, so we can treat any color channel as alpha
    vec4 fgColor = alpha * v_color;
    vec4 bgColor = v_backgroundColor * (1.0 - alpha);
    gl_FragColor = bgColor + fgColor;
}
