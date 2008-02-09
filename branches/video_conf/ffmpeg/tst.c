#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <avcodec.h>


struct vc_tcp_video_header
{
    uint16_t   ssize;
    uint16_t   width;
    uint16_t   height;
    uint16_t   nkeyframe;
    uint32_t   size;
    uint32_t   fourcc;
    uint32_t   unk01;
    uint32_t   timestamp;
};

int main(int argc, char *argv[]) {

  uint8_t sequence_layer[] = { 0x0f, 0xf1, 0x80, 0x01, 0x40, 0x0f};
  AVCodec * wmv3 = NULL;
  AVCodecContext *ctx = NULL;
  AVFrame *frame = NULL;
  AVFrame *rgb_frame = NULL;
  int opened = 0;
  FILE *fd = fopen (argv[1], "r");
  FILE *out = fopen (argv[2], "w");
  uint8_t *buffer = NULL;
  uint8_t *rgb_buffer = NULL;
  struct vc_tcp_video_header header = {0};
  uint8_t    unk00;
  int got_picture = 0;
  int ret;
  int buffer_size = 0;

  if (!fd) {
    printf ("Error opening %s\n", argv[1]);
    return -1;
  }

  av_log_set_level (AV_LOG_ERROR);

  avcodec_register_all ();

  avcodec_init();

  wmv3 = avcodec_find_decoder_by_name("wmv3");
  ctx = avcodec_alloc_context();
  frame = avcodec_alloc_frame();
  rgb_frame = avcodec_alloc_frame();

  buffer_size = avpicture_get_size (PIX_FMT_RGB24, 320, 240);
  rgb_buffer = malloc (buffer_size);
  avpicture_fill ((AVPicture *) rgb_frame, rgb_buffer, PIX_FMT_RGB24, 320, 240);

  ctx->extradata = malloc (6 + FF_INPUT_BUFFER_PADDING_SIZE);
  ctx->extradata_size = 6;
  memcpy (ctx->extradata, sequence_layer, sizeof(sequence_layer));

  opened = avcodec_open(ctx, wmv3);

  printf("%p - %p - %p - %d\n", wmv3, ctx, frame, opened);

  printf ("Frame %d (%d) of size %dx%d has size : %d\n",
      header.timestamp, header.nkeyframe, header.width,
      header.height, header.size);

  while (!feof (fd)) {
    ret = fread (&unk00, 1, 1, fd);
    if (feof (fd )) break;
    ret = fread (&header, 1, 24, fd);
    printf ("Read %d chars\n", ret);
    printf ("Frame %d (%d) of size %dx%d has size : %d\n",
        header.timestamp, header.nkeyframe, header.width,
        header.height, header.size);
    ctx->width = header.width;
    ctx->height = header.height;
    ctx->bits_per_sample = 0x18;
    buffer = malloc (header.size);
    ret = fread (buffer, 1, header.size, fd);
    printf ("Read %d chars\n", ret);
    ret = avcodec_decode_video (ctx, frame, &got_picture, buffer, header.size);
    printf ("Decoded %d bytes. Got picture : %d\n", ret, got_picture);

    memset (rgb_buffer, 0, buffer_size);
    img_convert ((AVPicture *) rgb_frame, PIX_FMT_RGB24,
        (AVPicture *)frame, ctx->pix_fmt, ctx->width, ctx->height);

    fwrite (rgb_buffer, 1, buffer_size, out);


    free (buffer);
  }

  fclose (fd);
  fclose (out);

  return 0;
}
