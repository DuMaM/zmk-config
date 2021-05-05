/*
 * Copyright (c) 2020 The ZMK Contributors
 *
 * SPDX-License-Identifier: MIT
 */

#pragma once

#if CONFIG_ZMK_SPLIT_MAIN
#define PINOFFSET 0
#error "NOOOOOOOO"
#else
#define PINOFFSET 6
#endif