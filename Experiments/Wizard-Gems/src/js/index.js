import "jquery";
import "jquery-validation";
import seedrandom from "seedrandom";
import "lodash";
import "jspsych";
import "jspsych/plugins/jspsych-html-keyboard-response";
import "jspsych/plugins/jspsych-image-keyboard-response";
import "jspsych/plugins/jspsych-external-html";
import "./render-mustache-template";
import "./wizard-gem-trial";
import moment from "moment/src/moment";
import {
  saveAttrition,
  saveData,
  getIpAddress,
  setupFormValidation,
  getFormData,
  generateCompletionCode,
  endExperiment,
} from "./utils";
import {
  generateRandomGemValues,
  getShuffledGemColors,
  getCorrectAnswer,
} from "./gems";
import "jspsych/css/jspsych.css";
import "bootswatch/dist/flatly/bootstrap.min.css";
import "@dashboardcode/bsmultiselect/dist/css/BsMultiSelect.min.css";
import "../css/index.css";

const demo_mode = true;

// * Setup
document.title = "Wizard Gems";

// * Functions

// * Constants
const experiment_name = "wizard_gems";
const version_date = "2019-08-10";
const default_iti = 500; // in ms; bug in jspsych 6.0.x where this param isn't respected at jsPsych.init
const start_time = moment.utc().format();
const equation_weights = _.shuffle([0.55, 0.25, 0.125, 0.0625, 0.0125]); // ! randomizing every time
const num_gems = 5;
const gem_colors = {
  blue: "#00C3FF",
  red: "#FF4100",
  yellow: "#FFB60D",
  green: "#44E80C",
  purple: "#9200F0",
};

const consent = {
  type: "render-mustache-template",
  url: "src/html/consent.html",
  cont_btn: "consentButton",
  post_trial_gap: default_iti,
  data: {
    experiment_phase: "consent",
  },
  render_data: {
    compensation: "0.05",
    duration: "2 minutes",
  },
};

const attrition = {
  type: "render-mustache-template",
  url: "src/html/attrition.html",
  cont_btn: "continueButton",
  post_trial_gap: default_iti, // 0,
  data: {
    form_name: "attritionForm",
    form_id: "#attritionForm",
    experiment_phase: "attrition",
  },
  render_data: {},
  on_complete_callbacks: {
    setupFormValidation: [setupFormValidation, "attritionForm"],
  },
  check_fn: function() {
    const valid = $(this.data.form_id).valid();
    if (valid) {
      return true;
    }
    return false;
  },
  on_finish: saveAttrition,
};

const instructions = {
  type: "render-mustache-template",
  url: "src/html/instructions.html",
  cont_btn: "continueButton",
  post_trial_gap: default_iti,
  data: {
    experiment_phase: "instructions",
  },
  render_data: {},
  on_start: saveAttrition,
};

/* Logic for the survey is a little tricky, since
 it requires that the external page be fully loaded
 before we set up form validation on it.
*/
const survey = {
  type: "render-mustache-template",
  url: "src/html/survey.html",
  cont_btn: "surveyFormButton",
  post_trial_gap: default_iti, // 0,
  data: {
    form_name: "surveyForm",
    form_id: "#surveyForm",
    experiment_phase: "survey",
  },
  render_data: {},
  on_start: function() {
    $("body").css({ "background-color": "rgb(255, 255, 255)" });
  },
  on_complete_callbacks: {
    setupFormValidation: [setupFormValidation, "surveyForm"],
  },
  check_fn: function() {
    const valid = $(this.data.form_id).valid();
    if (valid) {
      this.data.form_data = JSON.stringify(getFormData(this.data.form_id));
      return true;
    }
    return false;
  },
};

const completion_code = generateCompletionCode("exa", "mple");
const debriefing = {
  type: "external-html",
  url: "src/html/debriefing.html",
  cont_btn: "debriefingButton",
  post_trial_gap: default_iti,
  data: {
    completion_code,
    experiment_phase: "debriefing",
  },
};

// * Example trial
const gem_values = generateRandomGemValues(num_gems);
console.log("gem_values", gem_values);
const correct_answer = getCorrectAnswer(gem_values, equation_weights);
console.log("correct_answer", correct_answer);
const example_trial = {
  type: "wizard-gem-trial",
  phase: "learning",
  container_width: 700,
  gem_values: gem_values,
  correct_answer: correct_answer,
  gem_colors: getShuffledGemColors(gem_colors),
  feedback_color: "rgba(0, 0, 0, 1)",
  bar_length: 300,
  bar_thickness: 65,
  prompt:
    "<p>How much is this wizard gem worth? Respond by clicking on the right-most bar. " +
    "After recording your response, you may press the 'Next' button. " +
    "Only your initial response will be recorded.</p>",
  post_trial_gap: default_iti,
};

// * Preload everything
// const preload_stimuli = [];

// * Timeline
const timeline = [example_trial];
// const timeline = [
//   consent,
//   attrition,
//   instructions,
//   example_trial,
//   survey,
//   debriefing,
// ];

// * Start the experiment
jsPsych.init({
  timeline: timeline,
  show_progress_bar: false,
  // preload_images: preload_stimuli,
  on_finish: async function() {
    seedrandom(Date.now());
    const turk_info = jsPsych.turk.turkInfo();
    const ip_address = await getIpAddress();
    const props = {
      experiment_name: experiment_name,
      workerId: turk_info.workerId,
      assignmentId: turk_info.assignmentId,
      hitId: turk_info.hitId,
      experiment_start_time: start_time,
      experiment_end_time: moment.utc().format(),
      total_time: jsPsych.totalTime(),
      ip_address,
      version_date: version_date,
      anon_id: jsPsych.randomization.randomID(15),
      demo_mode,
      completion_code: completion_code,
    };
    endExperiment(props);
  },
});
