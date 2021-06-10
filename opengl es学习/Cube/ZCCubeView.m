//
//  ZCCubeView.m
//  opengl es学习
//
//  Created by 张葱 on 2021/5/31.
//

#import "ZCCubeView.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 coordPosition;
    GLKVector2 textureCoord;
    GLKVector3 normal;
}CubeVertex;

@interface ZCCubeView()

@property (nonatomic, strong) EAGLContext  *context;
@property (nonatomic, strong) CAEAGLLayer *openglLayer;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) GLuint renderBuffer;
//顶点&纹理数组
@property (nonatomic, assign) CubeVertex *vertices;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSUInteger rotationAngle;

@property (nonatomic, assign) GLuint VBObuffer;
//旋转矩阵
@property (nonatomic, assign) GLKMatrix4 rorationMat;

@property (nonatomic, assign) GLKVector3 lightDirection;//平行光光照方向
@end

@implementation ZCCubeView


- (void)removeFromSuperview {
    if([EAGLContext currentContext] == self.context) {
          [EAGLContext setCurrentContext:nil];
        }
        [self clearBuffers];
        if (self.program) {
            glDeleteProgram(self.program);
            self.program = 0;
        }
        if (_vertices) {
            free(_vertices);
            _vertices = nil;
        }
        [self.displayLink invalidate];
}

//清除帧缓存和渲染缓存区
- (void)clearBuffers {
    glDeleteFramebuffers(1, &_frameBuffer);
    self.frameBuffer = 0;
    glDeleteRenderbuffers(1, &_renderBuffer);
    self.renderBuffer = 0;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        _rotationAngle = 0;
        _rorationMat = GLKMatrix4Identity;//单位矩阵
        [self setUp];
    }
    return self;
}

//重定向layer 作为opengl的输出layer
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (void)setUp {
   [self setInitSource];//设置初始值
   [self setUpContext];
   [self prepareForSuface];
   [self clearBuffers];
   [self setUpRendBuffer];
   [self setUpFrameBuffer];
   [self setUpProgram];
   [self prepareCoordData];
   [self prepareRotationMat];
    CGSize size = self.bounds.size;
    CGFloat scale = [[UIScreen mainScreen] scale];
    glViewport(0, 0, size.width * scale, size.height * scale);
    [self setUpTexture];
    [self draw];
    [self startFilerAnimation];

}

//设置初始值
- (void)setInitSource {
    self.lightDirection = GLKVector3Make(1, -1, 0);//光源斜向下
}

// 开始一个滤镜动画
- (void)startFilerAnimation {
    //CADisplayLink 定时器
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(rotationCube)];
    
    //将displayLink 添加到runloop 运行循环
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSRunLoopCommonModes];
}



//1.设置layer基本配置
- (void)prepareForSuface {
    self.openglLayer = (CAEAGLLayer *)[self layer];
    self.openglLayer.contentsScale = [UIScreen mainScreen].scale;
    self.openglLayer.drawableProperties = @{kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8,kEAGLDrawablePropertyRetainedBacking:@false};
    
}

//初始化上下文
- (void)setUpContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
}

//初始化帧缓冲区 并绑定渲染缓存区
- (void)setUpFrameBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.renderBuffer);
}

//初始化渲染缓存区
- (void)setUpRendBuffer {
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, self.renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.openglLayer];
}

//初始化程序
- (void)setUpProgram {
    GLuint program =  glCreateProgram();
    NSString *vshPath =  [[NSBundle mainBundle]pathForResource:@"cube" ofType:@"vsh"];
    NSString *fshPath = [[NSBundle mainBundle]pathForResource:@"cube" ofType:@"fsh"];
    GLuint vshShader = [self shaderWithType:GL_VERTEX_SHADER path:vshPath];
    GLuint fshShader = [self shaderWithType:GL_FRAGMENT_SHADER path:fshPath];
    glAttachShader(program, vshShader);
    glAttachShader(program, fshShader);
    glLinkProgram(program);
    GLint status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if(!status) {
        char message[1024];
        glGetProgramInfoLog(self.program, sizeof(message), NULL, message);
        NSLog(@"program link error:%@",[NSString stringWithUTF8String:message]);
        glDeleteProgram(self.program);
        return;
    }
    glDeleteShader(vshShader);
    glDeleteShader(fshShader);
    glUseProgram(program);
    self.program = program;
    
}

- (void)setUpTexture {
    for (int i = 0; i < 6; i++) {
           NSString *imageName = [NSString stringWithFormat:@"%d.jpg",i];
           NSString *locationName = [NSString stringWithFormat:@"texture%d",i];
           [self prepareTextureInfoWithImage:imageName location:locationName texture:GL_TEXTURE0 + i index:i];
    }
}

- (void)prepareRotationMat {
     GLuint loc = glGetUniformLocation(self.program, "modalMat");
     glUniformMatrix4fv(loc, 1, GL_FALSE, &_rorationMat.m00);
}

- (void)rotationCube {
    _rotationAngle = (self.rotationAngle + 1) % 360;
    GLKMatrix4 rotaMat = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(_rotationAngle), 0.5, 0.7, 0.5);
    self.rorationMat = rotaMat;
    GLuint loc = glGetUniformLocation(self.program, "modalMat");
    glUniformMatrix4fv(loc, 1, GL_FALSE, &_rorationMat.m00);
    [self draw];
}

- (void)draw {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    //使用program
    glUseProgram(self.program);
    //绑定vbo buffer
    glBindBuffer(GL_ARRAY_BUFFER, self.VBObuffer);
    //正背面剔除
    glEnable(GL_CULL_FACE);
    
    bool canInvert;
    GLKMatrix4 normalMatrix = GLKMatrix4InvertAndTranspose(self.rorationMat, &canInvert);
    if (canInvert) {//如果转置成功
        GLuint modelMatriUniformLocation = glGetUniformLocation(self.program, "normalMatrix");
        glUniformMatrix4fv(modelMatriUniformLocation, 1, 0, normalMatrix.m);
    }
    
    GLuint lightDirectionUniformLocation = glGetUniformLocation(self.program, "lightDirection");
    glUniform3fv(lightDirectionUniformLocation, 1, self.lightDirection.v);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)prepareTextureInfoWithImage:(NSString *)imageName location:(NSString *)locName texture:(GLenum)tex index:(GLint)index {
    UIImage *image = [UIImage imageNamed:imageName];
    CGImageRef imageRef = image.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    void * imageData = calloc(width * height * 4, sizeof(GLbyte));
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    GLuint texe;
    glGenTextures(1, &texe);
    glActiveTexture(tex);
    glBindTexture(GL_TEXTURE_2D, texe);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    GLsizei w = (GLsizei)width;
    GLsizei h = (GLsizei)height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    free(imageData);
    GLuint textureLocation = glGetUniformLocation(self.program, [locName UTF8String]);
    glUniform1i(textureLocation, index);
}

- (void)prepareCoordData {
    _vertices = malloc(sizeof(CubeVertex) * 36);
    //前面
    _vertices[0] = (CubeVertex){{-0.5, 0.5, 0.5}, {0.0, 1.0},{0.0, 0.0,1.0}};
    _vertices[1] = (CubeVertex){{-0.5, -0.5, 0.5}, {0.0, 0.0},{0.0, 0.0,1.0}};
    _vertices[2] = (CubeVertex){{0.5, -0.5, 0.5}, {1.0, 0.0},{0.0, 0.0,1.0}};
        
    _vertices[3] = (CubeVertex){{0.5, -0.5, 0.5}, {1.0, 0.0},{0.0, 0.0,1.0}};
    _vertices[4] = (CubeVertex){{0.5, 0.5, 0.5}, {1.0, 1.0},{0.0, 0.0,1.0}};
    _vertices[5] = (CubeVertex){{-0.5, 0.5, 0.5}, {0.0, 1.0},{0.0, 0.0,1.0}};
        
        //右面
    _vertices[6] = (CubeVertex){{0.5, 0.5, 0.5}, {0.0, 1.0},{1.0, 0.0,0.0}};
    _vertices[7] = (CubeVertex){{0.5, -0.5, 0.5}, {0.0, 0.0},{1.0, 0.0,0.0}};
    _vertices[8] = (CubeVertex){{0.5, -0.5, -0.5}, {1.0, 0.0},{1.0, 0.0,0.0}};
        
    _vertices[9] = (CubeVertex){{0.5, -0.5, -0.5}, {1.0, 0.0},{1.0, 0.0,0.0}};
    _vertices[10] = (CubeVertex){{0.5, 0.5, -0.5}, {1.0, 1.0},{1.0, 0.0,0.0}};
    _vertices[11] = (CubeVertex){{0.5, 0.5, 0.5}, {0.0, 1.0},{1.0, 0.0,0.0}};
        
        //后面
    _vertices[12] = (CubeVertex){{0.5, 0.5, -0.5}, {0.0, 1.0},{0.0, 0.0,-1.0}};
    _vertices[13] = (CubeVertex){{0.5, -0.5, -0.5}, {0.0, 0.0},{0.0, 0.0,-1.0}};
    _vertices[14] = (CubeVertex){{-0.5, -0.5, -0.5}, {1.0, 0.0},{0.0, 0.0,-1.0}};
        
    _vertices[15] = (CubeVertex){{-0.5, -0.5, -0.5}, {1.0, 0.0},{0.0, 0.0,-1.0}};
    _vertices[16] = (CubeVertex){{-0.5, 0.5, -0.5}, {1.0, 1.0},{0.0, 0.0,-1.0}};
    _vertices[17] = (CubeVertex){{0.5, 0.5, -0.5}, {0.0, 1.0},{0.0, 0.0,-1.0}};
        //左
    _vertices[18] = (CubeVertex){{-0.5, 0.5, -0.5}, {0.0, 1.0},{-1.0, 0.0,0.0}};
    _vertices[19] = (CubeVertex){{-0.5, -0.5, -0.5}, {0.0, 0.0},{-1.0, 0.0,0.0}};
    _vertices[20] = (CubeVertex){{-0.5, -0.5, 0.5}, {1.0, 0.0},{-1.0, 0.0,0.0}};
        
    _vertices[21] = (CubeVertex){{-0.5, -0.5, 0.5}, {1.0, 0.0},{-1.0, 0.0,0.0}};
    _vertices[22] = (CubeVertex){{-0.5, 0.5, 0.5}, {1.0, 1.0},{-1.0, 0.0,0.0}};
    _vertices[23] = (CubeVertex){{-0.5, 0.5, -0.5}, {0.0, 1.0},{-1.0, 0.0,0.0}};
        
        //上
    _vertices[24] = (CubeVertex){{-0.5, 0.5, -0.5}, {0.0, 1.0},{0.0, 1.0,0.0}};
    _vertices[25] = (CubeVertex){{-0.5, 0.5, 0.5}, {0.0, 0.0},{0.0, 1.0,0.0}};
    _vertices[26] = (CubeVertex){{0.5, 0.5, 0.5}, {1.0, 0.0},{0.0, 1.0,0.0}};
        
    _vertices[27] = (CubeVertex){{0.5, 0.5, 0.5}, {1.0, 0.0},{0.0, 1.0,0.0}};
    _vertices[28] = (CubeVertex){{0.5, 0.5, -0.5}, {1.0, 1.0},{0.0, 1.0,0.0}};
    _vertices[29] = (CubeVertex){{-0.5, 0.5, -0.5}, {0.0, 1.0},{0.0, 1.0,0.0}};
        
        //下
    _vertices[30] = (CubeVertex){{-0.5, -0.5, 0.5}, {0.0, 1.0},{0.0, -1.0,0.0}};
    _vertices[31] = (CubeVertex){{-0.5, -0.5, -0.5}, {0.0, 0.0},{0.0, -1.0,0.0}};
    _vertices[32] = (CubeVertex){{0.5, -0.5, -0.5}, {1.0, 0.0},{0.0, -1.0,0.0}};
        
    _vertices[33] = (CubeVertex){{0.5, -0.5, -0.5}, {1.0, 0.0},{0.0, -1.0,0.0}};
    _vertices[34] = (CubeVertex){{0.5, -0.5, 0.5}, {1.0, 1.0},{0.0, -1.0,0.0}};
    _vertices[35] = (CubeVertex){{-0.5, -0.5, 0.5}, {0.0, 1.0},{0.0, -1.0,0.0}};
        
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(CubeVertex) * 36, self.vertices, GL_STATIC_DRAW);
    GLuint indx = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(indx);
    glVertexAttribPointer(indx, 3, GL_FLOAT, GL_FALSE, sizeof(CubeVertex), NULL + offsetof(CubeVertex, coordPosition));
    GLuint textureCoordIndex = glGetAttribLocation(self.program, "coordPosition");
    glEnableVertexAttribArray(textureCoordIndex);
    glVertexAttribPointer(textureCoordIndex, 2, GL_FLOAT, GL_FALSE, sizeof(CubeVertex), NULL + offsetof(CubeVertex, textureCoord));
    
    
    GLuint normalIndex = glGetAttribLocation(self.program, "normal");
    glEnableVertexAttribArray(normalIndex);
    glVertexAttribPointer(normalIndex, 3, GL_FLOAT, GL_FALSE, sizeof(CubeVertex), NULL + offsetof(CubeVertex, normal));
    
    self.VBObuffer = buffer;
}



- (GLuint)shaderWithType:(GLenum)type path:(NSString *)sourcePath {
    GLuint shader = glCreateShader(type);
    NSString *content = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    
    const char *sourceContent = [content UTF8String];
    glShaderSource(shader, 1, &sourceContent, NULL);
    glCompileShader(shader);
    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if(status == GL_FALSE) {
        char message[512];
        glGetShaderInfoLog(shader, sizeof(message), NULL, message);
        NSLog(@"compile shader error: %@",[NSString stringWithUTF8String:message]);
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
