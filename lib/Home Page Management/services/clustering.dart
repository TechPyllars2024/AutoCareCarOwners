import 'dart:math';

class Gaussian {
  double mean;
  double variance;
  List<double> weights;

  Gaussian({required this.mean, required this.variance, required this.weights});
}

class GaussianMixtureModel {
  int numComponents;  // Number of clusters (components)
  List<Gaussian> components = [];
  int maxIterations = 100;

  GaussianMixtureModel(this.numComponents);

  // Fit the GMM to data (using basic EM algorithm)
  void fit(List<List<double>> data) {
    int numDataPoints = data.length;
    int numFeatures = data[0].length;

    // Initialize the means, variances, and weights randomly
    Random rand = Random();
    for (int i = 0; i < numComponents; i++) {
      double mean = rand.nextDouble() * 10;  // Random mean between 0 and 10
      double variance = rand.nextDouble() * 5 + 1;  // Random variance between 1 and 6
      components.add(Gaussian(mean: mean, variance: variance, weights: List.generate(numDataPoints, (_) => 1 / numComponents)));
    }

    for (int iter = 0; iter < maxIterations; iter++) {
      // Expectation Step: Calculate the probabilities for each data point belonging to each component
      List<List<double>> responsibilities = List.generate(numDataPoints, (_) => List.filled(numComponents, 0.0));
      for (int i = 0; i < numDataPoints; i++) {
        double totalProb = 0.0;
        for (int k = 0; k < numComponents; k++) {
          double prob = gaussianProbability(data[i], components[k]);
          responsibilities[i][k] = components[k].weights[i] * prob;
          totalProb += responsibilities[i][k];
        }
        for (int k = 0; k < numComponents; k++) {
          responsibilities[i][k] /= totalProb;
        }
      }

      // Maximization Step: Re-estimate the parameters (mean, variance, and weights)
      for (int k = 0; k < numComponents; k++) {
        double weightedSum = 0.0;
        double weightedMean = 0.0;
        double weightedVariance = 0.0;
        double totalResponsibility = 0.0;

        for (int i = 0; i < numDataPoints; i++) {
          totalResponsibility += responsibilities[i][k];
          weightedMean += responsibilities[i][k] * data[i][0];  // Using only first feature (simplified)
        }

        components[k].mean = weightedMean / totalResponsibility;

        // Recalculate variance
        for (int i = 0; i < numDataPoints; i++) {
          weightedVariance += responsibilities[i][k] * pow(data[i][0] - components[k].mean, 2);
        }

        components[k].variance = weightedVariance / totalResponsibility;
      }
    }
  }

  // Calculate the probability of a data point given the Gaussian distribution
  double gaussianProbability(List<double> dataPoint, Gaussian gaussian) {
    double exponent = -pow(dataPoint[0] - gaussian.mean, 2) / (2 * gaussian.variance);
    return exp(exponent) / sqrt(2 * pi * gaussian.variance);
  }

  // Predict the cluster for each data point
  List<int> predict(List<List<double>> data) {
    List<int> assignments = [];
    for (var point in data) {
      double maxProb = -double.infinity;
      int assignedCluster = 0;
      for (int i = 0; i < numComponents; i++) {
        double prob = gaussianProbability(point, components[i]);
        if (prob > maxProb) {
          maxProb = prob;
          assignedCluster = i;
        }
      }
      assignments.add(assignedCluster);
    }
    return assignments;
  }
}

void main() {
  List<List<double>> data = [
    [1.0], [1.2], [1.4], [3.0], [2.8], [7.0], [7.2], [8.0], [8.2]
  ];

  GaussianMixtureModel gmm = GaussianMixtureModel(2); // Assume we have 2 clusters
  gmm.fit(data);

  List<int> clusters = gmm.predict(data);

  // Print cluster assignments
  for (int i = 0; i < clusters.length; i++) {
    print('Data point ${data[i]} is assigned to cluster ${clusters[i]}');
  }
}
