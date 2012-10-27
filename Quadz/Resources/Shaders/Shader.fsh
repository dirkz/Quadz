//
//  Shader.fsh
//  Quadz
//
//  Created by Dirk Zimmermann on 10/26/12.
//  Copyright (c) 2012 Dirk Zimmermann. All rights reserved.
//

varying mediump vec4 v_color;

void main()
{
    gl_FragColor = v_color;
}
