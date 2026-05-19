import os
import onnx
from onnxruntime.quantization import quantize_dynamic, QuantType
from onnxconverter_common.float16 import convert_float_to_float16

def quantize_to_fp16(input_model_path, output_model_path):
    print(f"Mengonversi {input_model_path} ke FP16...")
    try:
        model = onnx.load(input_model_path)
        model_fp16 = convert_float_to_float16(model)
        onnx.save(model_fp16, output_model_path)
        print(f"Selesai! Tersimpan di {output_model_path}")
    except Exception as e:
        print(f"Gagal mengonversi ke FP16: {e}")

def quantize_to_int8(input_model_path, output_model_path):
    print(f"Mengonversi {input_model_path} ke INT8...")
    try:
        quantize_dynamic(
            model_input=input_model_path,
            model_output=output_model_path,
            weight_type=QuantType.QUInt8
        )
        print(f"Selesai! Tersimpan di {output_model_path}")
    except Exception as e:
        print(f"Gagal mengonversi ke INT8: {e}")

if __name__ == "__main__":
    # Daftar model yang akan dikompres
    models = [
        "deblurring_nafnet_2025may.onnx",
        "low_light_enhancement.onnx"
    ]
    
    for model_path in models:
        if os.path.exists(model_path):
            print(f"\n--- Memproses {model_path} ---")
            
            # FP16 Quantization (Disarankan untuk image processing, menjaga kualitas)
            fp16_path = model_path.replace(".onnx", "_fp16.onnx")
            quantize_to_fp16(model_path, fp16_path)
            
            # INT8 Quantization (Ukuran paling kecil, kualitas mungkin sedikit menurun)
            int8_path = model_path.replace(".onnx", "_int8.onnx")
            quantize_to_int8(model_path, int8_path)
        else:
            print(f"\nPeringatan: File {model_path} tidak ditemukan.")
            print("Pastikan file tersebut ada di folder yang sama dengan script ini.")
