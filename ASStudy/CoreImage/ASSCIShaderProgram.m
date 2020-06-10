//
//  ASSCIShaderProgram.m
//  ASStudy
//
//  Created by Adair Wang on 2020/6/8.
//  Copyright © 2020 Adair Studio. All rights reserved.
//

#import "ASSCIShaderProgram.h"
#import <OpenGLES/gltypes.h>
#import <OpenGLES/ES3/gl.h>

@interface ASSCIShaderProgram ()

@property (nonatomic, assign) GLuint shaderProgram;
@property (nonatomic, assign) GLuint vertexShader;
@property (nonatomic, assign) GLuint fragmentShader;

@end

@implementation ASSCIShaderProgram

- (instancetype)initWithVertexShaderContent:(NSString *)vertexShaderContent fragmentShaderContent:(NSString *)fragmentShaderContent
{
    self = [super init];
    if (self)
    {
        _vertexShader = [[self class] shaderWithSource:vertexShaderContent type:GL_VERTEX_SHADER];
        _fragmentShader = [[self class] shaderWithSource:fragmentShaderContent type:GL_FRAGMENT_SHADER];
        
        _shaderProgram = [[self class] programWithVertexShader:_vertexShader fragmentShader:_fragmentShader];
    }
    return self;
}

- (instancetype)initWithShaderFileName:(NSString *)shaderFileName
{
    NSString *vertexShaderFile = [NSString stringWithFormat:@"%@.vsh", shaderFileName];
    NSString *vertexShader = [NSString stringWithContentsOfFile:vertexShaderFile encoding:NSUTF8StringEncoding error:nil];
    
    NSString *fragmentShaderFile = [NSString stringWithFormat:@"%@.fsh", shaderFileName];
    NSString *fragmentShader = [NSString stringWithContentsOfFile:fragmentShaderFile encoding:NSUTF8StringEncoding error:nil];
    
    return [self initWithVertexShaderContent:vertexShader fragmentShaderContent:fragmentShader];
}

- (void)dealloc
{
    if (_shaderProgram != 0)
    {
        glDeleteProgram(_shaderProgram);
        _shaderProgram = 0;
    }
    
    if (_vertexShader != 0)
    {
        glDeleteShader(_vertexShader);
        _vertexShader = 0;
    }
    
    if (_fragmentShader != 0)
    {
        glDeleteShader(_fragmentShader);
        _fragmentShader = 0;
    }
}

- (void)bindVertexAttributeWithName:(NSString *)name toLocation:(uint32_t)location
{
    glBindAttribLocation(_shaderProgram, location, [name UTF8String]);
}

- (void)setUniformWithName:(NSString *)name toIntValue:(int32_t)intValue
{
    int location = [self uniformLocationWithName:name];
    [self useProgram];
    glUniform1i(location, intValue);
}

- (void)setUniformWithName:(NSString *)name toFloatValue:(float)floatValue
{
    int location = [self uniformLocationWithName:name];
    [self useProgram];
    glUniform1f(location, floatValue);
}

- (int)uniformLocationWithName:(NSString *)name
{
    int location = glGetUniformLocation(_shaderProgram, [name UTF8String]);
    assert(location >= 0);
    return location;
}

- (void)linkProgram
{
    assert(_shaderProgram != 0);
    
    glLinkProgram(_shaderProgram);

#ifdef DEBUG
    GLint length;
    glGetProgramiv(_shaderProgram, GL_INFO_LOG_LENGTH, &length);
    if (length > 0)
    {
        GLchar *log = (GLchar *)malloc(length);
        glGetProgramInfoLog(_shaderProgram, length, NULL, log);
        NSLog(@"Shader Program link info log:\n%s", log);
        free(log);
    }

    GLint param;
    glGetProgramiv(_shaderProgram, GL_LINK_STATUS, &param);
    assert(param == GL_TRUE);
#endif
}

- (void)useProgram
{
    glUseProgram(_shaderProgram);
}

+ (GLuint)shaderWithSource:(NSString *)source type:(GLenum)type
{
    assert(source.length > 0);
    
    GLuint shader = 0;
    if (source.length > 0)
    {
        shader = glCreateShader(type);
        const char *sourceUTF8String = [source UTF8String];
        glShaderSource(shader, 1, &sourceUTF8String, NULL);
        glCompileShader(shader);
        
#ifdef DEBUG
        GLint length;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &length);
        if (length > 0)
        {
            GLchar *log = (GLchar *)malloc(length);
            glGetShaderInfoLog(shader, length, NULL, log);
            NSLog(@"Shader compile info log:\n%s", log);
            free(log);
        }
        
        GLint param;
        glGetShaderiv(shader, GL_COMPILE_STATUS, &param);
        assert(param == GL_TRUE);
#endif
    }
    
    return shader;
}

+ (GLuint)programWithVertexShader:(GLuint)vertexShader fragmentShader:(GLuint)fragmentShader
{
    assert(vertexShader != 0 && fragmentShader != 0);
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    return program;
}

@end
