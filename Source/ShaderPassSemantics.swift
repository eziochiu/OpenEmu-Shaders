// Copyright (c) 2022, OpenEmu Team
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the OpenEmu Team nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY OpenEmu Team ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL OpenEmu Team BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Foundation

class ShaderPassBufferSemantics {
    public private(set) var data: UnsafeRawPointer
    
    init(data: UnsafeRawPointer) {
        self.data = data
    }
}

class ShaderPassTextureSemantics {
    let texture: UnsafeRawPointer
    let textureStride: Int
    let textureSize: UnsafeRawPointer
    let sizeStride: Int
    
    init(texture: UnsafeRawPointer, stride ts: Int, size: UnsafeRawPointer, stride ss: Int) {
        self.texture = texture
        self.textureStride = ts
        self.textureSize = size
        self.sizeStride = ss
    }
    
    convenience init(texture: UnsafeRawPointer, size: UnsafeRawPointer) {
        self.init(texture: texture, stride: 0, size: size, stride: 0)
    }
}

public class ShaderPassSemantics {
    private(set) var textures: [ShaderTextureSemantic: ShaderPassTextureSemantics] = [:]
    private(set) var uniforms: [ShaderBufferSemantic: ShaderPassBufferSemantics] = [:]
    private(set) var parameters: [Int: ShaderPassBufferSemantics] = [:]
    
    func addTexture(_ texture: UnsafeRawPointer, size: UnsafeRawPointer, semantic: ShaderTextureSemantic) {
        textures[semantic] = ShaderPassTextureSemantics(texture: texture, size: size)
    }
    
    func addTexture(_ texture: UnsafeRawPointer,
                    stride ts: Int,
                    size: UnsafeRawPointer,
                    stride ss: Int,
                    semantic: ShaderTextureSemantic) {
        textures[semantic] = ShaderPassTextureSemantics(texture: texture, stride: ts, size: size, stride: ss)
    }
    
    func addUniformData(_ data: UnsafeRawPointer, semantic: ShaderBufferSemantic) {
        uniforms[semantic] = ShaderPassBufferSemantics(data: data)
    }
    
    func addUniformData(_ data: UnsafeRawPointer, forParameterAt index: Int) {
        parameters[index] = ShaderPassBufferSemantics(data: data)
    }
    
    func parameter(at index: Int) -> ShaderPassBufferSemantics? {
        parameters[index]
    }
}
