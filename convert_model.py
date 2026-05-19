import os
# Paksa menggunakan legacy Keras (Keras 2) untuk membaca bobot lawas (weights)
os.environ['TF_USE_LEGACY_KERAS'] = '1'

import tensorflow as tf
import tf_keras as keras
from tf_keras import layers
from huggingface_hub import snapshot_download
import tf2onnx
import onnx

def build_dce_net():
    input_img = keras.Input(shape=[None, None, 3], name='input_image')
    conv1 = layers.Conv2D(32, (3, 3), strides=(1, 1), activation='relu', padding='same')(input_img)
    conv2 = layers.Conv2D(32, (3, 3), strides=(1, 1), activation='relu', padding='same')(conv1)
    conv3 = layers.Conv2D(32, (3, 3), strides=(1, 1), activation='relu', padding='same')(conv2)
    conv4 = layers.Conv2D(32, (3, 3), strides=(1, 1), activation='relu', padding='same')(conv3)
    int_con1 = layers.Concatenate(axis=-1)([conv4, conv3])
    conv5 = layers.Conv2D(32, (3, 3), strides=(1, 1), activation='relu', padding='same')(int_con1)
    int_con2 = layers.Concatenate(axis=-1)([conv5, conv2])
    conv6 = layers.Conv2D(32, (3, 3), strides=(1, 1), activation='relu', padding='same')(int_con2)
    int_con3 = layers.Concatenate(axis=-1)([conv6, conv1])
    x_r = layers.Conv2D(24, (3, 3), strides=(1, 1), activation='tanh', padding='same')(int_con3)
    return keras.Model(inputs=input_img, outputs=x_r)

def download_and_convert():
    print("Mendownload model dari Hugging Face...")
    path = snapshot_download(repo_id="keras-io/low-light-image-enhancement")
    
    print("Membangun arsitektur dasar model...")
    base_model = build_dce_net()
    
    print("Memuat bobot (weights) model...")
    weights_path = os.path.join(path, "variables", "variables")
    base_model.load_weights(weights_path)
    
    print("Menyatukan logika pencerahan (Curve Iterations) ke dalam model...")
    # Zero-DCE aslinya hanya mengeluarkan parameter kurva. 
    # Agar siap pakai di mobile, kita satukan perhitungan warnanya ke dalam model ONNX langsung.
    input_img = keras.Input(shape=[None, None, 3], name='input_image')
    x_r = base_model(input_img)
    
    x_r_list = tf.split(x_r, num_or_size_splits=8, axis=-1)
    enhanced = input_img
    for i in range(8):
        enhanced = enhanced + x_r_list[i] * (tf.square(enhanced) - enhanced)
        
    full_model = keras.Model(inputs=input_img, outputs=enhanced, name="ZeroDCE_Full")

    onnx_model_path = "low_light_enhancement.onnx"
    print(f"\nMengonversi model siap pakai ke format ONNX: {onnx_model_path}...")
    
    spec = (tf.TensorSpec((None, None, None, 3), tf.float32, name='input_image'),)
    onnx_model, _ = tf2onnx.convert.from_keras(full_model, input_signature=spec, opset=13)
    
    onnx.save(onnx_model, onnx_model_path)
    print("\nSelesai! Model berhasil disimpan sebagai", onnx_model_path)

if __name__ == "__main__":
    download_and_convert()
