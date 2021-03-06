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
  uint8_t *buffer = NULL;
  uint8_t *yuv_buffer = NULL;
  uint8_t *rgb_buffer = NULL;
  FILE *fd = NULL;
  FILE *out = NULL;
  struct vc_tcp_video_header header = {0};
  uint8_t unk00 = 0;
  int got_picture = 0;
  int ret;
  int yuv_buffer_size = 0;
  int buffer_size = 0;
  char exec_buf[1024];

  if (argc != 3) {
    fprintf (stderr, "Usage : %s input_file output_file\n", argv[0]);
    return -1;
  }

  fd = fopen (argv[1], "r");
  out = fopen (argv[2], "w");

  if (!fd || !out) {
    printf ("Error opening %s or %s\n", argv[1], argv[2]);
    return -1;
  }

  av_log_set_level (AV_LOG_DEBUG);

  avcodec_register_all ();

  avcodec_init();

  wmv3 = avcodec_find_encoder_by_name("wmv3");
  ctx = avcodec_alloc_context();
  frame = avcodec_alloc_frame();
  rgb_frame = avcodec_alloc_frame();

  buffer_size = avpicture_get_size (PIX_FMT_RGB24, 320, 240);
  rgb_buffer = malloc (buffer_size);
  avpicture_fill ((AVPicture *) rgb_frame, rgb_buffer, PIX_FMT_RGB24, 320, 240);

  yuv_buffer_size = avpicture_get_size (PIX_FMT_YUV420P, 320, 240);
  yuv_buffer = malloc (yuv_buffer_size);
  avpicture_fill ((AVPicture *) frame, yuv_buffer, PIX_FMT_YUV420P, 320, 240);

  ctx->width = 320;
  ctx->height = 240;
  ctx->bits_per_sample = 0x18;
  ctx->pix_fmt = PIX_FMT_YUV420P;
  ctx->time_base = AV_TIME_BASE_Q;

  opened = avcodec_open(ctx, wmv3);

  printf("%p - %p - %p - %d\n", wmv3, ctx, frame, opened);

  header.ssize = 24;
  header.width = 320;
  header.height = 240;
  header.nkeyframe = 0;
  header.size = 0;
  header.fourcc = 0x33564D57;
  header.unk01 = 0;
  header.timestamp = 0;

  buffer = malloc (buffer_size);
  while (!feof (fd)) {
    ret = fread (rgb_buffer, 1, buffer_size, fd);

    printf ("Read %d bytes\n", ret);
    printf("rc_buffer_size = %d\n", ctx->rc_buffer_size);
    img_convert ((AVPicture *) frame, PIX_FMT_YUV420P,
		 (AVPicture *)rgb_frame, PIX_FMT_RGB24, 
		 320, 240);

    ret = avcodec_encode_video (ctx, buffer, buffer_size, frame);
    printf ("Encoded %d bytes\n", ret);

    printf("%d - %d - %d - %d\n", buffer[200],
	   buffer[300], buffer[400], buffer[500]);
    if (ret >= 0) {
      header.size = ret;
      header.nkeyframe = ! ctx->coded_frame->key_frame;
      fwrite (&unk00, 1, 1, out);
      fwrite (&header, 1, 24, out);
      fwrite (buffer, 1, ret, out);
    } else {
      break;
    }
  }

  free (buffer);
  free (rgb_buffer);
  fclose (fd);
  fclose (out);

  return 0;
}
