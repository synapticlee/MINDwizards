import "jquery";
import "jquery-validation";
import "seedrandom";
import "@dashboardcode/bsmultiselect";
import "jspsych";
import moment from "moment/src/moment";

export function getShuffledGemColors() {
  const gem_colors = {
    blue: "#00C3FF",
    red: "#FF4100",
    yellow: "#FFB60D",
    green: "#44E80C",
    purple: "#9200F0",
  };
  const shuffled_color_names = _.shuffle(Object.keys(gem_colors));
  const shuffled_gem_colors = _.pick(gem_colors, shuffled_color_names);
  return Object.values(shuffled_gem_colors);
}

export async function endExperiment(props) {
  jsPsych.data.addProperties(props);
  const file_name = `${props.experiment_name}_data_${props.anon_id}_${
    props.version_date
  }.csv`;
  console.log("jsPsych CSV data:", jsPsych.data.get().csv());
  try {
    const result = await saveData(file_name, jsPsych.data.get().csv());
    console.log("result", result);
  } catch (error) {
    console.log(error);
  }
  if (props.demo_mode) {
    jsPsych.data.displayData();
    return;
  }
  let el = jsPsych.getDisplayElement();
  el.innerHTML = `<p id="completionPara" class="jumbotron success bg-success text-white">
    Thanks for participating! Your completion code is:
    <br><br>
    <strong>${props.completion_code}</strong>
    <br><br>
    Please be sure to copy it into the corresponding box at the HIT
    to receive compensation!
    </p>`;
}

export async function getIpAddress() {
  let response = await fetch("src/py/get_ip.py");
  return response.text();
}

export async function logVisitor(experiment_name, version_date) {
  const windowDimensions = [
    window.screen.width,
    window.screen.height,
    window.innerWidth,
    window.innerHeight,
  ];
  let ip_address = await getIpAddress();
  let data = [navigator.userAgent, windowDimensions, ip_address];
  let csv_line = data.join(",") + "\n";
  await saveData(`${experiment_name}_visitors_${version_date}.csv`, csv_line);
}

export function saveAttrition() {
  const turk_info = Object.values(jsPsych.turk.turkInfo());
  turk_info.push(moment.utc().format()); // add condition
  console.log("turkInfo", turk_info);
  let csv_line = turk_info.join(",") + "\n";
  console.log("csv_line", csv_line);
  saveData("attrition.csv", csv_line);
}

export async function saveData(experiment_name, file_name, data) {
  console.log("data:", data);
  let saved_data =
    localStorage.getItem(`saved_data_${experiment_name}`) === "true";
  if (saved_data) console.log("Already saved!");
  const result = await $.ajax({
    type: "post",
    contentType: "application/json; charset=UTF-8",
    async: true,
    cache: false,
    url: "src/py/save_data.py", // path to the script that will handle saving data
    data: JSON.stringify({
      file_name: file_name,
      file_data: data,
    }),
  })
    .done(function(data) {
      localStorage.setItem(`saved_data_${experiment_name}`, true);
      console.log("Saved data", data);
    })
    .fail(function(error) {
      localStorage.setItem(`saved_data_${experiment_name}`, false);
      console.log("Error saving data", error);
    });

  return result;
}

export function setupFormValidation(formName) {
  $.validator.addMethod(
    "selectValidEntry",
    function(value, element, arg) {
      return value !== "NA" && value !== "";
    },
    "Please select a valid answer from the dropdown list."
  );

  $.validator.addMethod("needsSelection", function(value, element) {
    const count = $(element).find("option:selected").length;
    return count > 0;
  });

  $.validator.addMethod(
    "regex",
    function(value, element, regexp) {
      return this.optional(element) || regexp.test(value);
    },
    "Please check your input."
  );

  $("#race").bsMultiSelect({
    useCss: true,
  });

  $(`form[name='${formName}']`).validate({
    // Specify validation rules
    rules: {
      // The key name on the left side is the name attribute
      // of an input field. Validation rules are defined
      // on the right side
      age: {
        required: true,
        min: 18,
        max: 120,
      },

      race: {
        needsSelection: true,
      },

      gender: {
        required: true,
        selectValidEntry: true,
      },

      attritionAnswer: {
        required: true,
        regex: /^\s*I will answer open-ended questions.\s*$/, // \s* : any number of white spaces
      },
    },

    messages: {
      age: {
        required: "Please enter your age",
        min: "Please enter a valid adult age",
        max: "Please enter a valid adult age",
      },

      race: {
        needsSelection: "Please select at least one race",
      },

      gender: {
        required: "Please select your self-identifed gender",
      },

      attritionAnswer: {
        required: "Please enter the text in italics, including the period.",
        regex: "Please enter the text in italics, including the period.",
      },
    },

    ignore: ':hidden:not("#race")', // necessary due to bsMultiSelect

    // Highlight on error
    highlight: function(element, errorClass, validClass) {
      $(element).addClass("is-invalid");
    },

    // Remove error highlighting
    unhighlight: function(element, errorClass, validClass) {
      $(element).removeClass("is-invalid");
    },
  });

  $.validator.addClassRules("selectValidEntry", {
    selectValidEntry: true,
  });
}

export function getFormData(formId) {
  const inputs = $(`${formId} :input`);
  let formData = {};
  for (const input of inputs) {
    if (input.name === "") continue;
    formData[input.name] = $(input).val();
  }
  return formData;
}

export function initializeFormData(data) {
  if (data === null) {
    return;
  }
  // Assuming that each key is actually an input field id
  for (const [key, val] of Object.entries(data)) {
    $(`#${key}`).val(val);
  }
}

export function generateCompletionCode(prefix, suffix) {
  let code = "";
  for (const i of _.range(0, 10)) {
    let this_num = _.random(0, 9);
    let this_char = this_num.toString();
    code = code + this_char;
  }
  code = `${code}-${prefix}-`;

  for (let i of _.range(0, 10)) {
    let this_num = _.random(0, 9);
    let this_char = this_num.toString();
    code = code + this_char;
  }
  code = `${code}-${suffix}`;
  return code;
}
