import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Funzione che mappa l'angolo ai 4 possibili valori
def map_angle_to_range(angle):
    angle = (angle + 180) % 360 - 180  # Normalize angle to [-180, 180]
    if (-22.5 <= angle <= 22.5) or (157.5 <= angle or angle <= -157.5):
        return 0
    elif (22.5 < angle <= 67.5) or (-157.5 < angle <= -112.5):
        return 1
    elif (67.5 < angle <= 112.5) or (-112.5 < angle <= -67.5):
        return 2
    elif (112.5 < angle <= 157.5) or (-67.5 < angle <= -22.5):
        return 3
    else:
        print(f"Unhandled angle: {angle}")
        return None

# Funzione per quantizzazione non uniforme
def non_uniform_quantize(value, fine_threshold, fine_step, coarse_step):
    if abs(value) <= fine_threshold:
        quantized_value = np.floor(value / fine_step) * fine_step
    else:
        quantized_value = np.floor(value / coarse_step) * coarse_step
    return quantized_value

# Parametri per la quantizzazione non uniforme
fine_threshold = 16  # Range near zero with fine quantization
fine_step = 1        # Fine quantization step
coarse_step = 64     # Coarse quantization step

# Genera una griglia di valori per X e Y
max_value = 1024
x = np.arange(-max_value, max_value, 1)
y = np.arange(-max_value, max_value, 1)
X, Y = np.meshgrid(x, y)
num_elements = X.size

# Calcola l'arctangente dei valori combinati di X e Y
Z_true = np.arctan2(X, Y)
Z_mapped = np.vectorize(map_angle_to_range)(np.degrees(Z_true))

# Applica la quantizzazione non uniforme
vectorized_quantize = np.vectorize(non_uniform_quantize)
X_quantized = vectorized_quantize(X, fine_threshold, fine_step, coarse_step)
Y_quantized = vectorized_quantize(Y, fine_threshold, fine_step, coarse_step)

# Calcola l'arctangente per la griglia quantizzata
Z_quantized = np.arctan2(X_quantized, Y_quantized)
Z_quantized_mapped = np.vectorize(map_angle_to_range)(np.degrees(Z_quantized))

# Calcola l'errore tra la griglia originale e quella quantizzata
absolute_error = np.abs(Z_quantized_mapped - Z_mapped) != 0
non_zero_error_count = np.count_nonzero(absolute_error)

# Output statistico degli errori
print(f"Number of wrong guesses: {non_zero_error_count}")
print(f"Number of elements: {num_elements}")
print(f"RELATIVE WRONG GUESSES: {(non_zero_error_count / num_elements) * 100:.2f}%")

coarse_lut_size = (max_value - fine_threshold)/(coarse_step)
print(f"TOTAL LUT ENTRIES : {(coarse_lut_size + fine_threshold)**2}")

# Grafico 3D
fig = plt.figure(figsize=(14, 7))

# Grafico della griglia originale
ax1 = fig.add_subplot(121, projection='3d')
ax1.plot_surface(X, Y, Z_mapped, cmap='viridis')
ax1.set_xlabel('X (Scala 10 bit)')
ax1.set_ylabel('Y (Scala 10 bit)')
ax1.set_zlabel('Angolo mappato')
ax1.set_title('Griglia Originale')

# Grafico della griglia quantizzata
ax2 = fig.add_subplot(122, projection='3d')
ax2.plot_surface(X_quantized, Y_quantized, Z_quantized_mapped, cmap='viridis')
ax2.set_xlabel('X (Quantizzato)')
ax2.set_ylabel('Y (Quantizzato)')
ax2.set_zlabel('Angolo mappato')
ax2.set_title('Griglia Quantizzata (Non Uniforme)')

# Grafico dell'errore
fig_error = plt.figure(figsize=(7, 7))
ax_error = fig_error.add_subplot(111, projection='3d')
ax_error.plot_surface(X, Y, absolute_error, cmap='inferno')
ax_error.set_xlabel('X (Scala 10 bit)')
ax_error.set_ylabel('Y (Scala 10 bit)')
ax_error.set_zlabel('Errore Assoluto')
ax_error.set_title('Errore Assoluto')

# Mostra i grafici
plt.show()
