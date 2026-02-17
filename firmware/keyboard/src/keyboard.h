#ifndef LOCAL_KEYBOARD_HEADER
#define LOCAL_KEYBOARD_HEADER

#include <stdint.h>
#include <zephyr/devicetree.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/usb/class/hid.h>

extern uint64_t keyflags;

#define NUM_INPUTS 4
#define NUM_SOURCES 3

#define USERNODE DT_PATH(zephyr_user)
#define ZEPHYR_USER_NODE DT_PATH(zephyr_user)


#define KBIT(source, input) ((source) * NUM_INPUTS + (input))

#define KFLAG_SET(source, input) \
    (keyflags |=  (1ULL << KBIT(source, input)))

#define KFLAG_CLEAR(source, input) \
    (keyflags &= ~(1ULL << KBIT(source, input)))

#define KFLAG_TEST(f)  (keyflags & f)

#define KFLAG_LIST(X)             \
        X(KEY_1,       1, HID_KEY_A)  \
        X(KEY_2,      16, HID_KEY_B)  \
        X(KEY_3,     256, HID_KEY_C)  \
        X(KEY_A,       2, HID_KEY_D)  \
        X(KEY_B,      32, HID_KEY_E)    \
        X(KEY_C,     512, HID_KEY_F)     \
        X(KEY_D,       4, HID_KEY_G)       \
        X(KEY_E,      64, HID_KEY_H)      \
        X(KEY_F,    1024, HID_KEY_I)    \
        X(KEY_CTRL,    8, HID_KEY_J)    \
        X(KEY_SPACE, 128, HID_KEY_K) \
        X(KEY_ALT,  2048, HID_KEY_L)  \

typedef enum {
#define X(name, value, key) name = value,
    KFLAG_LIST(X)
#undef X
} kflag_t;


extern const char *const kflag_names[];


extern const struct gpio_dt_spec sources[];
extern const struct gpio_dt_spec inputs[];

int configure_keys();
#endif
