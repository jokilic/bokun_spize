const minimumHeight = 100.0;
const maximumHeight = 225.0;
const heightStep = 1.0;
const rulerItemExtent = 8.0;

double normalizedHeight(double height) {
  final clampedHeight = height.clamp(
    minimumHeight,
    maximumHeight,
  );
  final stepIndex = ((clampedHeight - minimumHeight) / heightStep).round();

  return minimumHeight + (stepIndex * heightStep);
}
