import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

    # Parameters for LUT computation
DELTA = 0.01  # Step size for ground truth grid
MAX_VALUE = 5  # Maximum saturation value for both x and y
LUT_STEP = 1.0  # Step size for LUT discretization


def compute_arctan_lut(delta, max_value, lut_step):
    """
    Compute the LUT for arctangent approximation and evaluate errors.

    Parameters:
    delta (float): Step size for generating ground truth x and y values.
    max_value (float): Maximum value for both x and y.
    lut_step (float): Step size for discretizing x and y in the LUT.

    Returns:
    tuple: A tuple containing x, y grids, approximate arctan values, and true arctan values.
    """
    # Generate finely spaced ground truth grid
    x = np.arange(0, max_value + delta, delta)
    y = np.arange(0, max_value + delta, delta)

    # Create 2D grids for ground truth x and y
    X, Y = np.meshgrid(x, y)

    # Compute true arctangent values in degrees
    true_arctan = np.degrees(np.arctan2(Y, X))

    # Discretize x and y for LUT (using lut_step)
    lut_x = np.arange(0, max_value + lut_step, lut_step)
    lut_y = np.arange(0, max_value + lut_step, lut_step)

    # Approximate arctangent values using LUT
    approx_arctan = np.zeros_like(true_arctan)
    for i in range(X.shape[0]):
        for j in range(X.shape[1]):
            # Find the closest LUT values for x and y
            closest_x = np.round(X[i, j] / lut_step) * lut_step
            closest_y = np.round(Y[i, j] / lut_step) * lut_step

            # Avoid division by zero
            if closest_x != 0 or closest_y != 0:
                approx_arctan[i, j] = np.degrees(np.arctan2(closest_y, closest_x))

    return X, Y, true_arctan, approx_arctan

def plot_errors(X, Y, true_arctan, approx_arctan):
    """
    Plot the absolute and relative errors in 3D.

    Parameters:
    X (ndarray): X grid values.
    Y (ndarray): Y grid values.
    true_arctan (ndarray): True arctangent values.
    approx_arctan (ndarray): Approximate arctangent values from LUT.
    """
    # Compute absolute and relative errors
    absolute_error = np.abs(true_arctan - approx_arctan)
    relative_error = np.where(true_arctan != 0, absolute_error / true_arctan * 100, 0)

    # Plot absolute error
    fig1 = plt.figure()
    ax1 = fig1.add_subplot(111, projection='3d')
    ax1.plot_surface(X, Y, absolute_error, cmap='viridis', edgecolor='none')
    ax1.set_title('Absolute Error (degrees)')
    ax1.set_xlabel('X')
    ax1.set_ylabel('Y')
    ax1.set_zlabel('Error (degrees)')
    plt.show()

    # Plot relative error
    fig2 = plt.figure()
    ax2 = fig2.add_subplot(111, projection='3d')
    ax2.plot_surface(X, Y, relative_error, cmap='plasma', edgecolor='none')
    ax2.set_title('Relative Error (%)')
    ax2.set_xlabel('X')
    ax2.set_ylabel('Y')
    ax2.set_zlabel('Error (%)')
    plt.show()

if __name__ == "__main__":

    # Compute LUT and errors
    X, Y, true_arctan, approx_arctan = compute_arctan_lut(DELTA, MAX_VALUE, LUT_STEP)

    # Plot errors
    plot_errors(X, Y, true_arctan, approx_arctan)
