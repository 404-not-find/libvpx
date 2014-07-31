#!/bin/sh
##
##  Copyright (c) 2014 The WebM project authors. All Rights Reserved.
##
##  Use of this source code is governed by a BSD-style license
##  that can be found in the LICENSE file in the root of the source
##  tree. An additional intellectual property rights grant can be found
##  in the file PATENTS.  All contributing project authors may
##  be found in the AUTHORS file in the root of the source tree.
##
##  This file tests vpxdec. To add new tests to this file, do the following:
##    1. Write a shell function (this is your test).
##    2. Add the function to vpxdec_tests (on a new line).
##
. $(dirname $0)/tools_common.sh

# Environment check: Make sure input is available.
vpxdec_verify_environment() {
  if [ ! -e "${VP8_IVF_FILE}" ] || [ ! -e "${VP9_WEBM_FILE}" ]; then
    echo "Libvpx test data must exist in LIBVPX_TEST_DATA_PATH."
    return 1
  fi
}

# Echoes yes to stdout when vpxdec exists according to vpx_tool_available().
vpxdec_available() {
  [ -n "$(vpx_tool_available vpxdec)" ] && echo yes
}

# Wrapper function for running vpxdec in noblit mode. Requires that
# LIBVPX_BIN_PATH points to the directory containing vpxdec. Positional
# parameter one is used as the input file path. Positional parameter two, when
# present, is interpreted as a boolean flag that means the input should be sent
# to vpxdec via pipe from cat instead of directly.
vpxdec() {
  local input="${1}"
  local pipe_input=${2}

  if [ $# -gt 2 ]; then
    # shift away $1 and $2 so the remaining arguments can be passed to vpxdec
    # via $@.
    shift 2
  fi

  local decoder="${LIBVPX_BIN_PATH}/vpxdec${VPX_TEST_EXE_SUFFIX}"

  if [ -z "${pipe_input}" ]; then
    eval "${VPX_TEST_PREFIX}" "${decoder}" "$input" --summary --noblit "$@" \
        ${devnull}
  else
    cat "${input}" \
        | eval "${VPX_TEST_PREFIX}" "${decoder}" - --summary --noblit "$@" \
            ${devnull}
  fi
}

vpxdec_can_decode_vp8() {
  if [ "$(vpxdec_available)" = "yes" ] && \
     [ "$(vp8_decode_available)" = "yes" ]; then
    echo yes
  fi
}

vpxdec_can_decode_vp9() {
  if [ "$(vpxdec_available)" = "yes" ] && \
     [ "$(vp9_decode_available)" = "yes" ]; then
    echo yes
  fi
}

vpxdec_vp8_ivf() {
  if [ "$(vpxdec_can_decode_vp8)" = "yes" ]; then
    vpxdec "${VP8_IVF_FILE}"
  fi
}

vpxdec_vp8_ivf_pipe_input() {
  if [ "$(vpxdec_can_decode_vp8)" = "yes" ]; then
    vpxdec "${VP8_IVF_FILE}" -
  fi
}

vpxdec_vp9_webm() {
  if [ "$(vpxdec_can_decode_vp9)" = "yes" ] && \
     [ "$(webm_io_available)" = "yes" ]; then
    vpxdec "${VP9_WEBM_FILE}"
  fi
}

vpxdec_tests="vpxdec_vp8_ivf
              vpxdec_vp8_ivf_pipe_input
              vpxdec_vp9_webm"

run_tests vpxdec_verify_environment "${vpxdec_tests}"
