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
varying vec2 v_texCoord0;

void main()
{
    vec4 textureColor = texture2D(s_texture0, v_texCoord0);
    gl_FragColor = v_color * textureColor;
}
