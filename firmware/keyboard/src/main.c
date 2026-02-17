

#include <stdint.h>
#include <string.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>
#include <zephyr/logging/log.h>
#include <zephyr/logging/log_core.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/dt-bindings/gpio/gpio.h>

#include "usb.h"
#include "keyboard.h"


LOG_MODULE_REGISTER(keybaord_main, LOG_LEVEL_INF);
void add_key_to_report(uint8_t key, uint8_t *keyreport);


int main(void)
{
    int err;
    if ((err = usbd_setup_helper()) != 0)
    {
        LOG_ERR("Failed to register USB device! (err: %d)\n", err);
        return err;
    }

    LOG_INF("USBD ready!");

    while (!hid_ready)
    {
        LOG_INF("Waiting for HID device to be ready...\n");
        k_sleep(K_SECONDS(1));
    }
    LOG_INF("HID ready!");

    if ((err = configure_keys()) != 0)
    {
        LOG_ERR("Failed to configure initial key states! (err: %d)", err);
        return err;
    }

    LOG_INF("starting keyscan");
    uint64_t keyflags_prev = 0;
    uint8_t keyreport[KB_BOOT_REPORT_SIZE] = {0};
    while (1)
    {
        for (uint8_t s = 0; s < NUM_SOURCES; s++)
        {
            gpio_pin_set_dt(&sources[s], 1);
            for (uint8_t i = 0; i < NUM_INPUTS; i++)
            {
                if (gpio_pin_get_dt(&inputs[i]) > 0)
                    KFLAG_SET(s, i);
                else
                    KFLAG_CLEAR(s, i);
            }
            gpio_pin_set_dt(&sources[s], 0);
        }



        if (keyflags != keyflags_prev)
        {
            memset(keyreport, 0, KB_BOOT_REPORT_SIZE);
#define X(name, value, key) if (KFLAG_TEST(value) != 0) {add_key_to_report(key, keyreport);}
KFLAG_LIST(X)
#undef X
            test_kb_send_letter(keyreport);
        }

        keyflags_prev = keyflags;
        k_usleep(1000);
    }

}



void add_key_to_report(uint8_t key, uint8_t *keyreport)
{
    for (int i = 2; i < KB_BOOT_REPORT_SIZE; i++)
    {
        if (keyreport[i] == 0)
        {
            keyreport[i] = key;
            return;
        }
    }
    LOG_WRN("Max level of key rollover reached!");
}
