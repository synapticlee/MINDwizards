import "lodash";

export function getShuffledGemColors(gem_colors) {
  const shuffled_color_names = _.shuffle(Object.keys(gem_colors));
  const shuffled_gem_colors = _.pick(gem_colors, shuffled_color_names);
  return shuffled_gem_colors;
}

export function generateRandomGemValues(num_values) {
  // Generate random gem values between 0 and 100 for each weight
  const gem_values = [];
  for (const i of _.range(num_values)) {
    gem_values.push(_.random(0, 100, false));
  }
  return gem_values;
}

export function getCorrectAnswer(gem_values, equation_weights) {
  const zipped = _.zip(gem_values, equation_weights);
  let sum = 0;
  for (const arr of zipped) {
    const [val, weight] = [...arr];
    sum += val * weight;
  }
  return sum;
}
