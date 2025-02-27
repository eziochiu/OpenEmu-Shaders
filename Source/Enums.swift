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

enum ShaderTextureSemantic: Int, RawRepresentable, CaseIterable, CustomStringConvertible {
    /// Identifies the input texture to the filter chain.
    ///
    /// Shaders refer to the input texture via the `Original` and `OriginalSize` symbols.
    case original
    
    /// Identifies the output texture from the previous pass.
    ///
    /// Shaders can refer to the previous source texture via
    /// the `Source` and `SourceSize` symbols.
    ///
    /// - Note: If the filter chain is executing the first pass, this is the same as
    /// `Original`.
    case source
    
    /// Identifies the historical input textures.
    ///
    /// Shaders can refer to the history textures via the
    /// `OriginalHistoryN` and `OriginalSizeN` symbols, where `N`
    /// specifies the number of `Original` frames back to read.
    ///
    /// - Note: To read 2 frames prior, use `OriginalHistory2` and `OriginalSize2`.
    case originalHistory
    
    /// Identifies the pass output textures.
    ///
    /// Shaders can refer to the output of prior passes via the
    /// `PassOutputN` and `PassOutputSizeN` symbols, where `N` specifies the
    /// pass number.
    ///
    /// - NOTE: In pass 5, sampling the output of pass 2
    /// would use `PassOutput2` and `PassOutputSize2`.
    case passOutput
    
    /// Identifies the pass feedback textures.
    ///
    /// Shaders can refer to the output of the previous
    /// frame of pass `N` via the `PassFeedbackN` and `PassFeedbackSizeN`
    /// symbols, where `N` specifies the pass number.
    ///
    /// - NOTE: To sample the output of pass 2 from the prior frame,
    /// use `PassFeedback2` and `PassFeedbackSize2`.
    case passFeedback
    
    /// Identifies the lookup or user textures.
    ///
    /// Shaders refer to user lookup or user textures by name as defined
    /// in the `.slangp` file.
    case user
    
    var description: String {
        switch self {
        case .original:
            return "Original"
        case .source:
            return "Source"
        case .originalHistory:
            return "OriginalHistory"
        case .passOutput:
            return "PassOutput"
        case .passFeedback:
            return "PassFeedback"
        case .user:
            return "User"
        }
    }
}

enum ShaderBufferSemantic: Int, CaseIterable, CustomStringConvertible {
    /// Identifies the 4x4 float model-view-projection matrix buffer.
    ///
    /// Shaders refer to the matrix constant via the `MVP` symbol.
    ///
    case mvp
    
    /// Identifies the vec4 float containing the viewport size of the current pass.
    ///
    /// Shaders refer to the viewport size constant via the `OutputSize` symbol.
    ///
    /// - NOTE: The `x` and `y` fields refer to the size of the output in pixels.
    /// The `z` and `w` fields refer to the inverse; `1/x` and `1/y`.
    case outputSize
    
    /// Identifies the vec4 float containing the final viewport output size.
    ///
    /// Shaders refer to the final output size constant via the `FinalViewportSize` symbol.
    ///
    /// - NOTE: The `x` and `y` fields refer to the size of the output in pixels.
    /// The `z` and `w` fields refer to the inverse; `1/x` and `1/y`.
    case finalViewportSize
    
    /// Identifies the uint containing the frame count.
    ///
    /// Shaders refer to the frame count constant via the `FrameCount` symbol.
    ///
    /// - NOTE: This value increments by one each frame.
    case frameCount
    
    /// Identifies the int containing the frame direction; 1 is forward, -1 is backwards.
    ///
    /// Shaders refer to the frame direction constant via the `FrameDirection` symbol.
    case frameDirection
    
    /// Identifies a float parameter buffer.
    ///
    /// Shaders refer to float parameters by name.
    case floatParameter
    
    var description: String {
        switch self {
        case .mvp:
            return "MVP"
        case .outputSize:
            return "OutputSize"
        case .finalViewportSize:
            return "FinalViewportSize"
        case .frameCount:
            return "FrameCount"
        case .frameDirection:
            return "FrameDirection"
        case .floatParameter:
            return "FloatParameter"
        }
    }
}

enum Constants {
    static let maxShaderPasses = 26
    static let maxTextures = 8
    static let maxParameters = 256
    static let maxFrameHistory = 128
    static let maxConstantBuffers = 2
    static let maxShaderBindings = 16
}

public enum ShaderPassScale: CaseIterable {
    case invalid, source, absolute, viewport
}

public enum ShaderPassFilter: Int, CaseIterable {
    case unspecified, linear, nearest
}

public enum ShaderPassWrap: Int, CaseIterable {
    case border, edge, `repeat`, mirroredRepeat
    
    static let `default`: Self = .border
}

extension OEMTLPixelFormat {
    var isNative: Bool {
        switch self {
        case .abgr8Unorm, .rgba8Unorm, .r5g5b5a1Unorm, .b5g6r5Unorm, .bgra4Unorm:
            return false
            
        case .bgra8Unorm, .bgrx8Unorm:
            return true
            
        default:
            return false
        }
    }
    
    // Returns the number of bytes per pixel for the given format; otherwise, 0 if the format is not supported
    var bytesPerPixel: Int {
        switch self {
        case .abgr8Unorm, .rgba8Unorm, .bgra8Unorm, .bgrx8Unorm:
            return 4
            
        case .b5g6r5Unorm, .r5g5b5a1Unorm, .bgra4Unorm:
            return 2
            
        default:
            return 4
        }
    }
}

extension MTLPixelFormat {
    // swiftlint: disable cyclomatic_complexity
    /// Converts a GL Slang format string to Metal
    init(glslangFormat str: String) {
        switch str {
        case "R8_UNORM":
            self = .r8Unorm
        case "R8_UINT":
            self = .r8Uint
        case "R8_SINT":
            self = .r8Sint
        case "R8G8_UNORM":
            self = .rg8Unorm
        case "R8G8_UINT":
            self = .rg8Uint
        case "R8G8_SINT":
            self = .rg8Sint
        case "R8G8B8A8_UNORM":
            self = .rgba8Unorm
        case "R8G8B8A8_UINT":
            self = .rgba8Uint
        case "R8G8B8A8_SINT":
            self = .rgba8Sint
        case "R8G8B8A8_SRGB":
            self = .rgba8Unorm_srgb
        case "A2B10G10R10_UNORM_PACK32":
            self = .rgb10a2Unorm
        case "A2B10G10R10_UINT_PACK32":
            self = .rgb10a2Uint
        case "R16_UINT":
            self = .r16Uint
        case "R16_SINT":
            self = .r16Sint
        case "R16_SFLOAT":
            self = .r16Float
        case "R16G16_UINT":
            self = .rg16Uint
        case "R16G16_SINT":
            self = .rg16Sint
        case "R16G16_SFLOAT":
            self = .rg16Float
        case "R16G16B16A16_UINT":
            self = .rgba16Uint
        case "R16G16B16A16_SINT":
            self = .rgba16Sint
        case "R16G16B16A16_SFLOAT":
            self = .rgba16Float
        case "R32_UINT":
            self = .r32Uint
        case "R32_SINT":
            self = .r32Sint
        case "R32_SFLOAT":
            self = .r32Float
        case "R32G32_UINT":
            self = .rg32Uint
        case "R32G32_SINT":
            self = .rg32Sint
        case "R32G32_SFLOAT":
            self = .rg32Float
        case "R32G32B32A32_UINT":
            self = .rgba32Uint
        case "R32G32B32A32_SINT":
            self = .rgba32Sint
        case "R32G32B32A32_SFLOAT":
            self = .rgba32Float
        default:
            self = .invalid
        }
    }
    
    /// Returns the number of bytes per pixel for the given format; otherwise, 0 if the format is not supported
    var bytesPerPixel: Int {
        switch self {
        case .a8Unorm, .r8Unorm, .r8Unorm_srgb, .r8Snorm, .r8Uint, .r8Sint:
            return 1
            
        case .r16Unorm, .r16Snorm, .r16Uint, .r16Sint, .r16Float:
            return 2
            
        case .rg8Unorm, .rg8Unorm_srgb, .rg8Snorm, .rg8Uint, .rg8Sint, .b5g6r5Unorm, .a1bgr5Unorm, .abgr4Unorm,
                .bgr5A1Unorm:
            return 2
            
        case .r32Uint, .r32Sint, .r32Float, .rg16Unorm, .rg16Snorm, .rg16Uint, .rg16Sint, .rg16Float, .rgba8Unorm,
                .rgba8Unorm_srgb, .rgba8Snorm, .rgba8Uint, .rgba8Sint, .bgra8Unorm, .bgra8Unorm_srgb, .rgb10a2Unorm,
                .rgb10a2Uint, .rg11b10Float, .rgb9e5Float, .bgr10a2Unorm, .bgr10_xr, .bgr10_xr_srgb:
            return 4
            
        case .rg32Uint, .rg32Sint, .rg32Float, .rgba16Unorm, .rgba16Snorm, .rgba16Uint, .rgba16Sint, .rgba16Float,
                .bgra10_xr, .bgra10_xr_srgb:
            return 8
            
        case .rgba32Uint, .rgba32Sint, .rgba32Float:
            return 16
            
        case .invalid:
            return 0
        default:
            return 0
        }
    }
}
