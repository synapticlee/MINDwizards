/**
 * wizard-gem-trial
 * Stefan Uddenberg
 *
 * plugin for displaying 5 vertical bars representing the values of 5
 * different wizard gems, in accordance with a predefined linear equation.
 * The subject must click on a 6th bar to record their response for how "valuable"
 * they believe the overall gem will be, based on its 5 constituent gem values.
 * On learning trials, they receive feedback and must adjust their response to match;
 * On test trials, they receive no feedback.
 * collecting a keyboard response, and doing a red screen with countdown
 * if the response is incorrect (otherwise no timeout).
 *
 * Built by editing Josh de Leeuw's jspsych-image-keyboard-response plugin.
 *
 **/

jsPsych.plugins["wizard-gem-trial"] = (function() {
  var plugin = {};

  plugin.info = {
    name: "wizard-gem-trial",
    description: "",
    parameters: {
      phase: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: "Trial phase",
        default: "learning",
        description: "If learning, show feedback, otherwise do not.",
      },
      container_width: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: "Stimulus container width",
        default: 800,
        description: "The width of the stimulus container.",
      },
      gem_values: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: "Gem values",
        default: undefined,
        array: true,
        description: "The gem values to be displayed",
      },
      gem_colors: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: "Gem colors",
        default: undefined,
        array: true,
        description: "The colors of the gems to be displayed",
      },
      feedback_color: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: "Feedback color",
        default: undefined,
        description: "The color of the feedback progress bar",
      },
      correct_answer: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: "Correct answer",
        default: undefined,
        description: "The correct answer for the current gem",
      },
      bar_length: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: "Bar width",
        default: null,
        description: "The width of the presented bars in pixels.",
      },
      bar_thickness: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: "Bar height",
        default: null,
        description: "The height of the presented bars in pixels.",
      },
      prompt: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: "Prompt",
        default: null,
        description: "Any content here will be displayed below the stimulus.",
      },
      stimulus_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: "Stimulus duration",
        default: null,
        description: "How long to show the stimulus.",
      },
      trial_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: "Trial duration",
        default: null,
        description: "How long to show trial before it ends.",
      },
    },
  };

  plugin.trial = function(display_element, trial) {
    // * Functions
    function addCSSRuleToDocument(rule) {
      try {
        let style = document.createElement("style");
        let sheet = document.head.appendChild(style).sheet;
        sheet.insertRule(rule, 0);
      } catch (error) {
        console.log("Failed to add rule; running on Chrome?");
        console.error(error);
      }
    }

    // store response
    const response = {
      rt: null,
      answer: null,
      correct_answer: trial.correct_answer,
    };

    $(".stimulus-container").css("width", `${trial.container_width}px`);
    const bar_offsets = {
      x: -(trial.bar_length - trial.bar_thickness) / 2,
      y: trial.bar_length > 100 ? -(trial.bar_length - 100) / 2 : 0,
    };
    let new_html = `<div class="container stimulus-container my-5" id="gemStimulusContainer">`;
    new_html += `<div class="row">`;
    for (const [i, gem_value] of trial.gem_values.entries()) {
      const gem_color = trial.gem_colors[i];
      new_html += `<div class="col-2" style="height:${trial.bar_length}px;">`;
      new_html += `<progress id="gem_${i}" style="width:${
        trial.bar_length
      }px; height:${
        trial.bar_thickness
      }px; transform: rotate(-90deg) translateX(${
        bar_offsets.x
      }px) translateY(${
        bar_offsets.y
      }px); color:${gem_color};" min="0" max="100" value="${gem_value}"/>`;
      new_html += `</div>`;
      const chrome_progress_bar_color_rule = `#gem_${i}::-webkit-progress-value { background-color: ${gem_color}; }`;
      const mozilla_progress_bar_color_rule = `#gem_${i}::-moz-progress-bar { background-color: ${gem_color}; }`;
      addCSSRuleToDocument(chrome_progress_bar_color_rule);
      addCSSRuleToDocument(mozilla_progress_bar_color_rule);
    }
    // add final slider and correct answer
    new_html += `<div class="col-2 divider">`;

    new_html += `<progress id="correctAnswer"
    class="invis"
    style="position: absolute; width:${trial.bar_length}px; height:${
      trial.bar_thickness
    }px; transform:  rotate(-90deg) translateX(${
      bar_offsets.x
    }px) translateY(${-trial.bar_length / 2}px);" min="0" max="100" value="${
      trial.correct_answer
    }"></progress>`;

    new_html += `<input type="range" id="responseSlider" style="position: absolute; width:${
      trial.bar_length
    }px; height:${
      trial.bar_thickness
    }px; transform: rotate(-90deg) translateX(${
      bar_offsets.x
    }px) translateY(${-trial.bar_length /
      2}px);" class="slider text-center not-clicked" value="0" min="0" max="100">`;
    new_html += `</div>`;

    // Close all divs
    new_html += `</div>`;
    new_html += `</div>`;

    //  Add rule coloring feedback color
    const chrome_progress_bar_color_rule = `#correctAnswer::-webkit-progress-value { background-color: ${
      trial.feedback_color
    }; }`;
    const mozilla_progress_bar_color_rule = `#correctAnswer::-moz-progress-bar { background-color: ${
      trial.feedback_color
    }; }`;

    const chrome_slider_thumb_rule = `.slider::-webkit-slider-thumb { height: ${
      trial.bar_thickness
    }px}`;
    const mozilla_slider_thumb_rule = `.slider::-moz-range-thumb { height: ${
      trial.bar_thickness
    }px}`;
    addCSSRuleToDocument(chrome_progress_bar_color_rule);
    addCSSRuleToDocument(mozilla_progress_bar_color_rule);
    addCSSRuleToDocument(chrome_slider_thumb_rule);
    addCSSRuleToDocument(mozilla_slider_thumb_rule);

    // add prompt
    if (trial.prompt !== null) {
      new_html += trial.prompt;
    }

    // add completion button
    new_html += `<div id="continueButtonContainer" class="container my-1 invis">
    <button class="btn btn-lg btn-primary" id="continueButton">Next</button>
    </div>`;

    // draw!
    display_element.innerHTML = new_html;

    // Record times
    const start_time = performance.now();

    // initialize slider
    $(".slider").on("change click input", function(event) {
      // * right now only recording time of first click
      if (response.rt === null) {
        const end_time = performance.now();
        response.rt = end_time - start_time;
        response.answer = $(this).val();
      }
      $(this).removeClass("not-clicked");
      //   $(this).prop("disabled", true);
      $("#correctAnswer").removeClass("invis");
      $("#continueButtonContainer").removeClass("invis");
    });

    // Initialize continue button
    $("#continueButton").on("click", function(event) {
      end_trial();
    });

    // function to end trial when it is time
    const end_trial = function() {
      // kill any remaining setTimeout handlers
      jsPsych.pluginAPI.clearAllTimeouts();

      // gather the data to store for the trial
      const trial_data = {
        rt: response.rt,
        page_rt: performance.now() - start_time,
        gem_values: trial.gem_values,
        response: response.answer,
        correct_answer: trial.correct_answer,
      };

      // clear the display
      display_element.innerHTML = "";

      // move on to the next trial
      jsPsych.finishTrial(trial_data);
    };

    // hide stimulus if stimulus_duration is set
    if (trial.stimulus_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function() {
        display_element.querySelector(
          "#gemStimulusContainer"
        ).style.visibility = "hidden";
      }, trial.stimulus_duration);
    }

    // end trial if trial_duration is set
    if (trial.trial_duration !== null) {
      jsPsych.pluginAPI.setTimeout(function() {
        end_trial();
      }, trial.trial_duration);
    }
  };

  return plugin;
})();
