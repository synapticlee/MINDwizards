/** (July 2019, Stefan Uddenberg)
The html-plugin will load and display an external html page, rendered with Mustache. To proceed to the next, the
user might either press a button on the page or a specific key. Afterwards, the page get hidden and
the plugin will wait of a specified time before it proceeds. Created by editing the external-html plugin.

*/
import Mustache from "mustache";
jsPsych.plugins["render-mustache-template"] = (function() {
  var plugin = {};

  plugin.info = {
    name: "render-mustache-template",
    description: "",
    parameters: {
      url: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: "URL",
        default: undefined,
        description: "The url of the external html page",
      },
      cont_key: {
        type: jsPsych.plugins.parameterType.KEYCODE,
        pretty_name: "Continue key",
        default: null,
        description: "The key to continue to the next page.",
      },
      cont_btn: {
        type: jsPsych.plugins.parameterType.STRING,
        pretty_name: "Continue button",
        default: null,
        description: "The button to continue to the next page.",
      },
      check_fn: {
        type: jsPsych.plugins.parameterType.FUNCTION,
        pretty_name: "Check function",
        default: function() {
          return true;
        },
        description: "",
      },
      force_refresh: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: "Force refresh",
        default: false,
        description: "Refresh page.",
      },
      // if execute_Script == true, then all javascript code on the external page
      // will be executed in the plugin site within your jsPsych test
      execute_script: {
        type: jsPsych.plugins.parameterType.BOOL,
        pretty_name: "Execute scripts",
        default: false,
        description:
          "If true, JS scripts on the external html file will be executed.",
      },
      render_data: {
        type: jsPsych.plugins.parameterType.OBJECT,
        pretty_name: "Mustache data",
        default: {},
        description: "The data to be rendered with Mustache.",
      },
      on_complete_callbacks: {
        type: jsPsych.plugins.parameterType.OBJECT,
        pretty_name: "Callbacks on load completion",
        default: {},
        description:
          "The callback functions to execute on successful load of the template.",
      },
    },
  };

  plugin.trial = function(display_element, trial) {
    const data = trial.render_data;
    var url = trial.url;
    if (trial.force_refresh) {
      url = trial.url + "?time=" + new Date().getTime();
    }

    load(display_element, url, data, function() {
      var t0 = new Date().getTime();
      for (let [key, arr] of Object.entries(trial.on_complete_callbacks)) {
        let func = arr.shift();
        let params = [...arr];
        func(...params);
      }

      var finish = function() {
        if (trial.check_fn && !trial.check_fn(display_element)) {
          return;
        }
        if (trial.cont_key) {
          // kill keyboard listeners
          jsPsych.pluginAPI.cancelKeyboardResponse(keyboardListener);
        }
        var trial_data = {
          rt: new Date().getTime() - t0,
          url: trial.url,
        };
        display_element.innerHTML = "";
        jsPsych.finishTrial(trial_data);
      };

      // by default, scripts on the external page are not executed with XMLHttpRequest().
      // To activate their content through DOM manipulation, we need to relocate all script tags
      if (trial.execute_script) {
        for (const scriptElement of display_element.getElementsByTagName(
          "script"
        )) {
          const relocatedScript = document.createElement("script");
          relocatedScript.text = scriptElement.text;
          scriptElement.parentNode.replaceChild(relocatedScript, scriptElement);
        }
      }

      if (trial.cont_btn) {
        display_element
          .querySelector("#" + trial.cont_btn)
          .addEventListener("click", finish);
      }
      if (trial.cont_key) {
        var keyboardListener = jsPsych.pluginAPI.getKeyboardResponse({
          callback_function: finish,
          valid_responses: [trial.cont_key],
          rt_method: "date",
          persist: false,
          allow_held_key: false,
        });
      }
    });
  };

  // helper to load via XMLHttpRequest
  function load(element, file, data, callback) {
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.open("GET", file, true);
    xmlhttp.onload = function() {
      if (xmlhttp.status == 200 || xmlhttp.status == 0) {
        // Check if loaded
        const template = xmlhttp.responseText;
        element.innerHTML = Mustache.render(template, data);
        callback();
      }
    };
    xmlhttp.send();
  }

  return plugin;
})();
