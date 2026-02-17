/*
 * usb.c handles the USB connection and messages
 * to the host system.
 */
#ifndef LOCAL_USB_HEADER_FILE
#define LOCAL_USB_HEADER_FILE


#include <stdbool.h>
#include <stdint.h>
#include <zephyr/device.h>
#include <zephyr/usb/usbd.h>
#include <zephyr/usb/usbd_msg.h>
#include <zephyr/usb/class/usbd_hid.h>
#include <zephyr/drivers/usb/udc_buf.h>


extern const struct device *hid_dev;
extern struct usbd_context *usbd_ctx;
extern bool hid_ready;

enum {
    KB_BOOT_REPORT_SIZE = 8
};


int usbd_setup_helper();
void test_kb_send_letter(uint8_t *keyreport);
int kb_hid_submit_boot_report(const uint8_t report[KB_BOOT_REPORT_SIZE]);


// Forward declare from usb_device.c
struct usbd_context *app_usbd_init(usbd_msg_cb_t msg_cb);


#endif
