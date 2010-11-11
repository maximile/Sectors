#ifndef NSViewTexture_h
#define NSViewTexture_h

#if defined(__cplusplus)
extern "C" {
#endif

#if defined(__gl_h_)
typedef GLenum GLenum_type;
typedef GLint  GLint_type;
#else
typedef unsigned int GLenum_type;
typedef int GLint_type;
#endif

#if defined(__OBJC__) && defined(APPKIT_EXTERN)
typedef id id_type;
#else
typedef void *id_type;
#endif

/* calls glTexImage2D(
             target,
             0,
             GL_RGBA,
             [view bounds].size.width,
             [view bounds].size.height,
             0,
             GL_RGBA,
             GL_UNSIGNED_BYTE,
             --contents of view--);
*/
extern void TexImageNSView(
    GLenum_type target,
    id_type     view);

/* calls glTexSubImage2D(
             target,
             0,
             xoffset,
             yoffset,
             [view bounds].size.width,
             [view bounds].size.height,
             GL_RGBA,
             GL_UNSIGNED_BYTE,
             --contents of view--);
*/
extern void TexSubImageNSView(
    GLenum_type target,
    id_type     view,
    GLint_type  xoffset,
    GLint_type  yoffset);

/* alignment should be -1, 0 or 1 for left/center/right respectively,
   or anything else for natural alignment */
/* initial_text and font_name should be UTF-8 encoded, and may be NULL */
extern id_type ConvenienceCreateNSTextView(
    unsigned    width,
    unsigned    height,
    const char *font_name,
    float       font_size,
    int         alignment,
    const char *initial_text);

/* calls [view release] */
extern void ConvenienceReleaseNSTextView(
    id_type view);

/* calls [view setString:[NSString stringWithUTF8String:text]] */
extern void ConvenienceSetNSTextViewText(
    id_type     view,
    const char *text);
    
#if defined(__cplusplus)
}
#endif

#endif
