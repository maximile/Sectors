#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

#import "NSViewTexture.h"

void TexSubImageNSView(
    GLenum target,
    id     view,
    GLint  xoffset,
    GLint  yoffset)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSSize size = [view bounds].size;
    
    unsigned width = size.width;
    unsigned height = size.height;

    // prior to 10.6 one could specify negative bytesPerRow to have the image
    // up the right way for OpenGL.  In 10.6, NSBitmapImageRep complains if
    // you try, so we're stuck with upside-down textures...
    unsigned char *buffer = malloc(width * height * 4);
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
        initWithBitmapDataPlanes:&buffer
                      pixelsWide:width
                      pixelsHigh:height
                   bitsPerSample:8
                 samplesPerPixel:4
                        hasAlpha:YES
                        isPlanar:NO
                  colorSpaceName:NSDeviceRGBColorSpace
                     bytesPerRow:width * 4
                    bitsPerPixel:32];
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmap];
    
    // this is 10.4+-only, what about 10.3?
    [view cacheDisplayInRect:[view bounds] toBitmapImageRep:bitmap];
        
    glTexSubImage2D(
        target,
        0,
        xoffset,
        yoffset,
        width,
        height,
        GL_RGBA,
        GL_UNSIGNED_BYTE,
        buffer);
    
    [image release];
    [bitmap release];
    free(buffer);
    
    [pool release];
}

void TexImageNSView(
    GLenum target,
    id     view)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSSize size = [view bounds].size;
    glTexImage2D(
        target,
        0,
        GL_RGBA,
        size.width,
        size.height,
        0,
        GL_RGBA,
        GL_UNSIGNED_BYTE,
        NULL);
    TexSubImageNSView(target, view, 0, 0);
    
    [pool release];
}

id ConvenienceCreateNSTextView(
    unsigned    width,
    unsigned    height,
    const char *font_name,
    float       font_size,
    int         alignment,
    const char *initial_text)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSRect rect = NSMakeRect(0.0f, 0.0f, (float)width, (float)height);
    NSTextView *view = [[NSTextView alloc] initWithFrame:rect];
    [view setBackgroundColor:[NSColor clearColor]];
    [view setTypingAttributes:
        [NSDictionary dictionaryWithObject:[NSColor whiteColor]
                                    forKey:NSForegroundColorAttributeName]];
    [view setFont:
        [NSFont fontWithName:[NSString stringWithUTF8String:font_name]
                        size:font_size]];
    switch (alignment)
    {
    case -1:
        [view setAlignment:NSLeftTextAlignment];
        break;
    case 0:
        [view setAlignment:NSCenterTextAlignment];
        break;
    case 1:
        [view setAlignment:NSRightTextAlignment];
        break;
    default:
        [view setAlignment:NSNaturalTextAlignment];
        break;
    }
                        
    if (initial_text != NULL)
    {
        [view setString:[NSString stringWithUTF8String:initial_text]];
    }
    
    [pool release];
    
    return view;
}

void ConvenienceReleaseNSTextView(
    id view)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [view release];
    [pool release];
}

void ConvenienceSetNSTextViewText(
    id          view,
    const char *text)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [view setString:[NSString stringWithUTF8String:text]];
    [pool release];
}
