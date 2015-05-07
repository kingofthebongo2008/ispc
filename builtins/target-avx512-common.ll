;;  Copyright (c) 2010-2015, Intel Corporation
;;  All rights reserved.
;;
;;  Redistribution and use in source and binary forms, with or without
;;  modification, are permitted provided that the following conditions are
;;  met:
;;
;;    * Redistributions of source code must retain the above copyright
;;      notice, this list of conditions and the following disclaimer.
;;
;;    * Redistributions in binary form must reproduce the above copyright
;;      notice, this list of conditions and the following disclaimer in the
;;      documentation and/or other materials provided with the distribution.
;;
;;    * Neither the name of Intel Corporation nor the names of its
;;      contributors may be used to endorse or promote products derived from
;;      this software without specific prior written permission.
;;
;;
;;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
;;   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
;;   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
;;   PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
;;   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;;   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;;   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  

define(`MASK',`i1')
define(`HAVE_GATHER',`1')
define(`HAVE_SCATTER',`1')

include(`util.m4')

stdlib_core()
scans()
reduce_equal(WIDTH)
rdrand_definition()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; broadcast/rotate/shuffle

declare <WIDTH x float> @__smear_float(float) nounwind readnone
declare <WIDTH x double> @__smear_double(double) nounwind readnone
declare <WIDTH x i8> @__smear_i8(i8) nounwind readnone
declare <WIDTH x i16> @__smear_i16(i16) nounwind readnone
declare <WIDTH x i32> @__smear_i32(i32) nounwind readnone
declare <WIDTH x i64> @__smear_i64(i64) nounwind readnone

declare <WIDTH x float> @__setzero_float() nounwind readnone
declare <WIDTH x double> @__setzero_double() nounwind readnone
declare <WIDTH x i8> @__setzero_i8() nounwind readnone
declare <WIDTH x i16> @__setzero_i16() nounwind readnone
declare <WIDTH x i32> @__setzero_i32() nounwind readnone
declare <WIDTH x i64> @__setzero_i64() nounwind readnone

declare <WIDTH x float> @__undef_float() nounwind readnone
declare <WIDTH x double> @__undef_double() nounwind readnone
declare <WIDTH x i8> @__undef_i8() nounwind readnone
declare <WIDTH x i16> @__undef_i16() nounwind readnone
declare <WIDTH x i32> @__undef_i32() nounwind readnone
declare <WIDTH x i64> @__undef_i64() nounwind readnone

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shuffle

define_shuffles()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; aos/soa

aossoa()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; half conversion routines

declare <8 x float> @llvm.x86.vcvtph2ps.256(<8 x i16>) nounwind readnone
; 0 is round nearest even
declare <8 x i16> @llvm.x86.vcvtps2ph.256(<8 x float>, i32) nounwind readnone

define <16 x float> @__half_to_float_varying(<16 x i16> %v) nounwind readnone {
  %r_0 = shufflevector <16 x i16> %v, <16 x i16> undef,
             <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %vr_0 = call <8 x float> @llvm.x86.vcvtph2ps.256(<8 x i16> %r_0)
  %r_1 = shufflevector <16 x i16> %v, <16 x i16> undef,
             <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %vr_1 = call <8 x float> @llvm.x86.vcvtph2ps.256(<8 x i16> %r_1)
  %r = shufflevector <8 x float> %vr_0, <8 x float> %vr_1,
           <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                       i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x float> %r
}

define <16 x i16> @__float_to_half_varying(<16 x float> %v) nounwind readnone {
  %r_0 = shufflevector <16 x float> %v, <16 x float> undef,
             <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %vr_0 = call <8 x i16> @llvm.x86.vcvtps2ph.256(<8 x float> %r_0, i32 0)
  %r_1 = shufflevector <16 x float> %v, <16 x float> undef,
             <8 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %vr_1 = call <8 x i16> @llvm.x86.vcvtps2ph.256(<8 x float> %r_1, i32 0)
  %r = shufflevector <8 x i16> %vr_0, <8 x i16> %vr_1,
           <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7,
                       i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  ret <16 x i16> %r
}

define float @__half_to_float_uniform(i16 %v) nounwind readnone {
  %v1 = bitcast i16 %v to <1 x i16>
  %vv = shufflevector <1 x i16> %v1, <1 x i16> undef,
           <8 x i32> <i32 0, i32 undef, i32 undef, i32 undef,
                      i32 undef, i32 undef, i32 undef, i32 undef>
  %rv = call <8 x float> @llvm.x86.vcvtph2ps.256(<8 x i16> %vv)
  %r = extractelement <8 x float> %rv, i32 0
  ret float %r
}

define i16 @__float_to_half_uniform(float %v) nounwind readnone {
  %v1 = bitcast float %v to <1 x float>
  %vv = shufflevector <1 x float> %v1, <1 x float> undef,
           <8 x i32> <i32 0, i32 undef, i32 undef, i32 undef,
                      i32 undef, i32 undef, i32 undef, i32 undef>
  ; round to nearest even
  %rv = call <8 x i16> @llvm.x86.vcvtps2ph.256(<8 x float> %vv, i32 0)
  %r = extractelement <8 x i16> %rv, i32 0
  ret i16 %r
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; math

declare void @__fastmath() nounwind 

;; round/floor/ceil

declare float @__round_uniform_float(float) nounwind readnone 
declare float @__floor_uniform_float(float) nounwind readnone 
declare float @__ceil_uniform_float(float) nounwind readnone 

declare double @__round_uniform_double(double) nounwind readnone 
declare double @__floor_uniform_double(double) nounwind readnone 
declare double @__ceil_uniform_double(double) nounwind readnone 

declare <WIDTH x float> @__round_varying_float(<WIDTH x float>) nounwind readnone 
declare <WIDTH x float> @__floor_varying_float(<WIDTH x float>) nounwind readnone 
declare <WIDTH x float> @__ceil_varying_float(<WIDTH x float>) nounwind readnone 
declare <WIDTH x double> @__round_varying_double(<WIDTH x double>) nounwind readnone 
declare <WIDTH x double> @__floor_varying_double(<WIDTH x double>) nounwind readnone 
declare <WIDTH x double> @__ceil_varying_double(<WIDTH x double>) nounwind readnone 

;; min/max

int64minmax()

declare float @__max_uniform_float(float, float) nounwind readnone 
declare float @__min_uniform_float(float, float) nounwind readnone 
declare i32 @__min_uniform_int32(i32, i32) nounwind readnone 
declare i32 @__max_uniform_int32(i32, i32) nounwind readnone 
declare i32 @__min_uniform_uint32(i32, i32) nounwind readnone 
declare i32 @__max_uniform_uint32(i32, i32) nounwind readnone 
declare double @__min_uniform_double(double, double) nounwind readnone 
declare double @__max_uniform_double(double, double) nounwind readnone 

declare <WIDTH x float> @__max_varying_float(<WIDTH x float>,
                                             <WIDTH x float>) nounwind readnone 
declare <WIDTH x float> @__min_varying_float(<WIDTH x float>,
                                             <WIDTH x float>) nounwind readnone 
declare <WIDTH x i32> @__min_varying_int32(<WIDTH x i32>, <WIDTH x i32>) nounwind readnone 
declare <WIDTH x i32> @__max_varying_int32(<WIDTH x i32>, <WIDTH x i32>) nounwind readnone 
declare <WIDTH x i32> @__min_varying_uint32(<WIDTH x i32>, <WIDTH x i32>) nounwind readnone 
declare <WIDTH x i32> @__max_varying_uint32(<WIDTH x i32>, <WIDTH x i32>) nounwind readnone 
declare <WIDTH x double> @__min_varying_double(<WIDTH x double>,
                                               <WIDTH x double>) nounwind readnone
declare <WIDTH x double> @__max_varying_double(<WIDTH x double>,
                                               <WIDTH x double>) nounwind readnone 

;; sqrt/rsqrt/rcp

declare float @__rsqrt_uniform_float(float) nounwind readnone 
declare float @__rcp_uniform_float(float) nounwind readnone 
declare float @__sqrt_uniform_float(float) nounwind readnone 
declare <WIDTH x float> @__rcp_varying_float(<WIDTH x float>) nounwind readnone 
declare <WIDTH x float> @__rsqrt_varying_float(<WIDTH x float>) nounwind readnone 

declare <WIDTH x float> @__sqrt_varying_float(<WIDTH x float>) nounwind readnone 

declare double @__sqrt_uniform_double(double) nounwind readnone
declare <WIDTH x double> @__sqrt_varying_double(<WIDTH x double>) nounwind readnone

;; bit ops

declare i32 @__popcnt_int32(i32) nounwind readnone
declare i64 @__popcnt_int64(i64) nounwind readnone 

ctlztz()

; FIXME: need either to wire these up to the 8-wide SVML entrypoints,
; or, use the macro to call the 4-wide ones twice with our 8-wide
; vectors...

;; svml

include(`svml.m4')
svml_stubs(float,f,WIDTH)
svml_stubs(double,d,WIDTH)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; reductions

declare i64 @__movmsk(<WIDTH x i1>) nounwind readnone 
declare i1 @__any(<WIDTH x i1>) nounwind readnone 
declare i1 @__all(<WIDTH x i1>) nounwind readnone 
declare i1 @__none(<WIDTH x i1>) nounwind readnone 

declare i16 @__reduce_add_int8(<WIDTH x i8>) nounwind readnone
declare i32 @__reduce_add_int16(<WIDTH x i16>) nounwind readnone

declare float @__reduce_add_float(<WIDTH x float>) nounwind readnone
declare float @__reduce_min_float(<WIDTH x float>) nounwind readnone 
declare float @__reduce_max_float(<WIDTH x float>) nounwind readnone 

declare i64 @__reduce_add_int32(<WIDTH x i32>) nounwind readnone
declare i32 @__reduce_min_int32(<WIDTH x i32>) nounwind readnone 
declare i32 @__reduce_max_int32(<WIDTH x i32>) nounwind readnone 
declare i32 @__reduce_min_uint32(<WIDTH x i32>) nounwind readnone 
declare i32 @__reduce_max_uint32(<WIDTH x i32>) nounwind readnone 

declare double @__reduce_add_double(<WIDTH x double>) nounwind readnone 
declare double @__reduce_min_double(<WIDTH x double>) nounwind readnone 
declare double @__reduce_max_double(<WIDTH x double>) nounwind readnone 

declare i64 @__reduce_add_int64(<WIDTH x i64>) nounwind readnone 
declare i64 @__reduce_min_int64(<WIDTH x i64>) nounwind readnone 
declare i64 @__reduce_max_int64(<WIDTH x i64>) nounwind readnone 
declare i64 @__reduce_min_uint64(<WIDTH x i64>) nounwind readnone 
declare i64 @__reduce_max_uint64(<WIDTH x i64>) nounwind readnone 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; unaligned loads/loads+broadcasts


declare <WIDTH x i8> @__masked_load_i8(i8 * nocapture, <WIDTH x i1> %mask) nounwind readonly
declare <WIDTH x i16> @__masked_load_i16(i8 * nocapture, <WIDTH x i1> %mask) nounwind readonly
declare <WIDTH x i32> @__masked_load_i32(i8 * nocapture, <WIDTH x i1> %mask) nounwind readonly
declare <WIDTH x i64> @__masked_load_i64(i8 * nocapture, <WIDTH x i1> %mask) nounwind readonly

masked_load_float_double()

gen_masked_store(i8)
gen_masked_store(i16)
gen_masked_store(i32)
gen_masked_store(i64)

define void @__masked_store_float(<WIDTH x float> * nocapture, <WIDTH x float>,
                                  <WIDTH x MASK>) nounwind alwaysinline {
  %ptr = bitcast <WIDTH x float> * %0 to <WIDTH x i32> *
  %val = bitcast <WIDTH x float> %1 to <WIDTH x i32>
  call void @__masked_store_i32(<WIDTH x i32> * %ptr, <WIDTH x i32> %val, <WIDTH x MASK> %2)
  ret void
}

define void @__masked_store_double(<WIDTH x double> * nocapture, <WIDTH x double>,
                                   <WIDTH x MASK>) nounwind alwaysinline {
  %ptr = bitcast <WIDTH x double> * %0 to <WIDTH x i64> *
  %val = bitcast <WIDTH x double> %1 to <WIDTH x i64>
  call void @__masked_store_i64(<WIDTH x i64> * %ptr, <WIDTH x i64> %val, <WIDTH x MASK> %2)
  ret void
}

define void @__masked_store_blend_i8(<WIDTH x i8>* nocapture, <WIDTH x i8>, 
                                     <WIDTH x i1>) nounwind alwaysinline {
  %v = load PTR_OP_ARGS(`<WIDTH x i8> ')  %0
  %v1 = select <WIDTH x i1> %2, <WIDTH x i8> %1, <WIDTH x i8> %v
  store <WIDTH x i8> %v1, <WIDTH x i8> * %0
  ret void
}

define void @__masked_store_blend_i16(<WIDTH x i16>* nocapture, <WIDTH x i16>, 
                                      <WIDTH x i1>) nounwind alwaysinline {
  %v = load PTR_OP_ARGS(`<WIDTH x i16> ')  %0
  %v1 = select <WIDTH x i1> %2, <WIDTH x i16> %1, <WIDTH x i16> %v
  store <WIDTH x i16> %v1, <WIDTH x i16> * %0
  ret void
}

define void @__masked_store_blend_i32(<WIDTH x i32>* nocapture, <WIDTH x i32>, 
                                      <WIDTH x i1>) nounwind alwaysinline {
  %v = load PTR_OP_ARGS(`<WIDTH x i32> ')  %0
  %v1 = select <WIDTH x i1> %2, <WIDTH x i32> %1, <WIDTH x i32> %v
  store <WIDTH x i32> %v1, <WIDTH x i32> * %0
  ret void
}

define void @__masked_store_blend_float(<WIDTH x float>* nocapture, <WIDTH x float>, 
                                        <WIDTH x i1>) nounwind alwaysinline {
  %v = load PTR_OP_ARGS(`<WIDTH x float> ')  %0
  %v1 = select <WIDTH x i1> %2, <WIDTH x float> %1, <WIDTH x float> %v
  store <WIDTH x float> %v1, <WIDTH x float> * %0
  ret void
}

define void @__masked_store_blend_i64(<WIDTH x i64>* nocapture,
                            <WIDTH x i64>, <WIDTH x i1>) nounwind alwaysinline {
  %v = load PTR_OP_ARGS(`<WIDTH x i64> ')  %0
  %v1 = select <WIDTH x i1> %2, <WIDTH x i64> %1, <WIDTH x i64> %v
  store <WIDTH x i64> %v1, <WIDTH x i64> * %0
  ret void
}

define void @__masked_store_blend_double(<WIDTH x double>* nocapture,
                            <WIDTH x double>, <WIDTH x i1>) nounwind alwaysinline {
  %v = load PTR_OP_ARGS(`<WIDTH x double> ')  %0
  %v1 = select <WIDTH x i1> %2, <WIDTH x double> %1, <WIDTH x double> %v
  store <WIDTH x double> %v1, <WIDTH x double> * %0
  ret void
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gather/scatter

define(`gather_scatter', `
declare <WIDTH x $1> @__gather_base_offsets32_$1(i8 * nocapture, i32, <WIDTH x i32>,
                                                 <WIDTH x i1>) nounwind readonly 
declare <WIDTH x $1> @__gather_base_offsets64_$1(i8 * nocapture, i32, <WIDTH x i64>,
                                                  <WIDTH x i1>) nounwind readonly 
declare <WIDTH x $1> @__gather32_$1(<WIDTH x i32>, 
                                    <WIDTH x i1>) nounwind readonly 
declare <WIDTH x $1> @__gather64_$1(<WIDTH x i64>, 
                                    <WIDTH x i1>) nounwind readonly 

declare void @__scatter_base_offsets32_$1(i8* nocapture, i32, <WIDTH x i32>,
                                          <WIDTH x $1>, <WIDTH x i1>) nounwind 
declare void @__scatter_base_offsets64_$1(i8* nocapture, i32, <WIDTH x i64>,
                                          <WIDTH x $1>, <WIDTH x i1>) nounwind 
declare void @__scatter32_$1(<WIDTH x i32>, <WIDTH x $1>,
                             <WIDTH x i1>) nounwind 
declare void @__scatter64_$1(<WIDTH x i64>, <WIDTH x $1>,
                              <WIDTH x i1>) nounwind 
')

gather_scatter(i8)
gather_scatter(i16)
gather_scatter(i32)
gather_scatter(float)
gather_scatter(i64)
gather_scatter(double)

packed_load_and_store()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; prefetch

define_prefetches()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; int8/int16 builtins

define_avgs()
declare_nvptx()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; reciprocals in double precision, if supported

rsqrtd_decl()
rcpd_decl()

transcendetals_decl()
trigonometry_decl()
