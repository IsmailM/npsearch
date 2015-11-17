$(document).ready(function() {
  'use strict';
  checkCollapseState();
  keepFooterFixedToBottom();
  addSeqValidation();
  inputValidation();

  $(document).bind('keydown', function (e) {
    if (e.ctrlKey && e.keyCode === 13 ) {
      $('#input').trigger('submit');
    }
  });
});

// Looks for a cookie (called 'NeuroHmmer_adv_params_status') to check the state of the adv_params box when it was last closed.
//  This function is called upon as soon as the website is loaded;
var checkCollapseState = function () {
  'use strict';
  if ($.cookie('NeuroHmmer_adv_params_status')){
    var adv_params_status = $.cookie('NeuroHmmer_adv_params_status');
    if (adv_params_status === 'open') {
      var btn = document.getElementById('adv_params_btn');
      btn.innerHTML = '<i class="fa fa-pencil-square-o"></i>&nbsp;&nbsp;Hide Advanced Parameters';
      $('#adv_params').addClass('in');
    }
  }
};

// This function simply ensures that the footer stays to fixed to the bottom of the window
var keepFooterFixedToBottom = function () {
  'use strict';
  $('#mainbody').css({'margin-bottom': (($('#footer').height()) + 15)+'px'});
  $(window).resize(function(){
      $('#mainbody').css({'margin-bottom': (($('#footer').height()) + 15)+'px'});
  });
};

// Creates a custom Validation for Jquery Validation plugin...
// It ensures that sequences are either protein or DNA data...
// If there are multiple sequences, ensures that they are of the same type
// It utilises the checkType function (further below)...
var addSeqValidation = function () {
  'use strict';
  jQuery.validator.addMethod('checkInputType', function(value, element) {
    var types = [],
        type  = '';
    if (value.charAt(0) === '>') {
      var seqs_array = value.split('>');
      for (var i = 1; i < seqs_array.length; i++) {
        var lines = seqs_array[i].split('\n');
        if (lines.length !== 0) {
          var clean_lines = jQuery.grep(lines,function(n){ return(n); });
          if (clean_lines.length !== 0){
            clean_lines.shift();
            var seq = clean_lines.join('');
            type = checkType(seq, 0.9);
            types.push(type);
            if ((type !== 'protein') && (type !== 'dna') && (type !== 'rna')) {
              return false;
            }
          }
        }
      }
      var firstType = types[0];
      for (var j = 0; j < types.length; j++) {
        if (types[j] !== firstType){
          return false;
        }
      }
      return true;
    } else {
      type = checkType(value, 0.9);
      if ((type !== 'protein') && (type !== 'dna') && (type !== 'rna')) {
        return false;
      } else {
        return true;
      }
    }
  }, '* The Input must be either DNA or protein sequence(s). Please ensure that your sequences do not contains any non-letter character(s). If there are multiple sequences, ensure that they are all of one type. ');
};


// A function that validates the input - Utilises Jquery.Validator.js
var inputValidation = function () {
  'use strict';
  var maxCharacters = $('#seq').attr('data-maxCharacters'); // returns a number or undefined
  $('#input').validate({
    rules: {
        seq: {
            minlength: 5,
            required: true,
            checkInputType: true,
            maxlength: maxCharacters // when undefined, maxlength is unlimited
        },
        'neuropeptides[]': {
           required: true,
        },
    },
    highlight: function(element) {
        $(element).closest('.form-group').addClass('has-error');
    },
    unhighlight: function(element) {
        $(element).closest('.form-group').removeClass('has-error');
    },
    errorElement: 'span',
    errorClass: 'help-block',
    errorPlacement: function(error, element) {
      if (element.parent().parent().attr('id') === 'validations_group') {
        var helpText = document.getElementById('lastValidation');
        error.insertAfter(helpText);
      } else {
        if (element.parent('.input-group').length) {
            error.insertAfter(element.parent());
        } else {
            error.insertAfter(element);
        }
      }
    },
    submitHandler: function(form) {
      $('#spinner').modal({
        backdrop: 'static',
        keyboard: 'false'
      });
      ajaxFunction();
    }
  });
};

// Sends the data within the form to the Server
var ajaxFunction = function () {
  'use strict';
  $.ajax({
    type: 'POST',
    url: $('#input').attr('action'),
    data: $('#input').serialize(),
    success: function(response){
      $('#results_box').show();
      $('#output').html(response);

      $('#mainbody').css({'background-color': '#fff'});
      $('#search').css({'background-color': '#F5F5F5'});
      $('#results').css({'border-top': '3px solid #DBDBDB'});
      $('#search').css({'margin-bottom': '0'});

      $('#spinner').modal('hide'); // remove progress notification
    },
    error: function (e, status) {
      var errorMessage;
      if (e.status == 500 || e.status == 400) {
        errorMessage = e.responseText;
        $('#results_box').show();
        $('#output').html(errorMessage);
        $('#spinner').modal('hide'); // remove progress notification
      } else {
        errorMessage = e.responseText;
        $('#results_box').show();
        $('#output').html('There seems to be an unidentified Error.');
        $('#spinner').modal('hide'); // remove progress notification
      }
    }
  });
};

// Function is called each time the Adv. Params button is pressed...
var changeAdvParamsBtnText = function () {
  'use strict';
  var btn = document.getElementById('adv_params_btn');
  if (btn.innerHTML === '<i class="fa fa-pencil-square-o"></i>&nbsp;&nbsp;Show Advanced Parameters') {
    btn.innerHTML = '<i class="fa fa-pencil-square-o"></i>&nbsp;&nbsp;Hide Advanced Parameters';
    $('#adv_params').collapse('show');
    $.cookie('NeuroHmmer_adv_params_status', 'open');
  }
  else {
    btn.innerHTML = '<i class="fa fa-pencil-square-o"></i>&nbsp;&nbsp;Show Advanced Parameters';
    $('#adv_params').collapse('hide');
    $.cookie('NeuroHmmer_adv_params_status', 'closed');
  }
};

// Changes the input to an examplar dna or protein sequence...
var examplarSequences = function (){
  'use strict';
  var seqs = '>gi|752421898|ref|XP_011230170.1| PREDICTED: glucagon [Ailuropoda melanoleuca]\n' +
             'MKSIYFVAGLFVMLVQGSWQRSLQDTEEKSRSLPAPQTDPLNDPDQMNEDKRHSQGTFTSDYSKYLDSRRAQDFVQWLMSTKRNKNNIAKRHDEFERHAEGTFTSDVSSYLEGQAAKEFIAWLVKGRGRRDFPEEVAIVEELRRRHADGSFSDEMNTVLDDLATRDFINWLLQTKITER\n' +
             '>gi|328711854|ref|XP_003244660.1| PREDICTED: uncharacterized protein LOC100571180 [Acyrthosiphon pisum]\n' +
             'MVKIGLPWLLLVLMKLTNREIKSDEIISIQEVYDICQAEPNTDICDLLEKSSSLVDLNKLDSPEKRRQKTVFSSWGGKRQSTYPYGGKRPAFSSWGGKRASDKHGRPKQTFSSWGGKRSDYDGYDNGEMDEHQMDKRELNGIKQDKNNYRNKMTKGIHALFTIFSDWSRDPEEKKGIRYAGIKSMRRSSDFFPWGGKRFTGDAK\n' +
             '>gi|301771746|ref|XP_002921293.1| PREDICTED: thyrotropin releasing hormone [Ailuropoda melanoleuca]\n' +
             'MPGPWLQLAMALTLTVAGIPGGRAQPEVAQQEAAMAPERAGLDDLLRQAQRLLFLREDLQRLRGNQGDLESEAQILQPDWLSKRQHPGKREGEAEEGVEEEEEEGGAVGPHKRQHPGRQEDVAAWSDVTLQKRQHPGRRAPLLGYAFTKRQHPGRRLVDSKAQRSWEAEEEDGEEEGGEPMPEKRQHPGKRALGSPCGPGAACGQASLLLGLLDDLSRGQGAEEKRQHPGRRAAWAREPLEE\n' +
             '>gi|328710353|ref|XP_003244236.1| PREDICTED: uncharacterized protein LOC100573178 [Acyrthosiphon pisum]\n' +
             'MTMSVTITILCILGSTFLLIMPDNTTASDKFFQTGGRFGKRHDEHIPDIRYAAMVKTRSVDNVPPRIERGFYISRYGKRSTNSITDPYYFTLCLPSYGIYCDFTGLPNLLRCKRIQPGACSNLNYVNEKTQMKPDNDIII\n' +
             '>gi|641659926|ref|XP_008181304.1| PREDICTED: uncharacterized protein LOC100570556 isoform X2 [Acyrthosiphon pisum]\n' +
             'MHKFFVQIYIFVLIIWAVEKSDCKQGACLNYGHSCWGAHGKRNVPNDLDSLIRYRMAVFKKSGHRDSFINPNADQSQEDIPNYYNIFKHYSKINSVKTNNDDTVDTWSLEPSNNLPSGGSYYEDQVLDPRIEYKIMKI\n' +
             '>gi|328717573|ref|XP_003246245.1| PREDICTED: uncharacterized protein LOC100568735 [Acyrthosiphon pisum]\n' +
             'MPHKINVGLVALAALAAAVLADPSVDRRASMGFMGMRGKKDRDQGGGGSGGDETSAAVDLDKRTMVFRRPMFDGGSRPAVFGGGSAEGFKRASMGFMGMRGKKDYYSNNKGSAAGFFGMRGKKVPSADAFYGVRGKKWPDHEDAVDADVQLSPIYILYRIIDELKSELSDRERNLVAAKFDEEREMR\n'
  document.getElementById('seq').value = seqs;
};

// FROM BIONODE-Seq - See https://github.com/bionode/bionode-seq
// Checks whether a sequence is a protein or dna sequence...
var checkType = function (sequence, threshold, length, index) {
  'use strict';
  if (threshold === undefined) {
    threshold = 0.9;
  }
  if (length === undefined) {
    length = 10000;
  }
  if (index === undefined) {
    index = 1;
  }
  var seq = sequence.slice(index - 1, length);

  var dnaSeq = seq.replace(/N/gi,'');
  var dnaTotal = dnaSeq.length;
  var acgMatch = ((dnaSeq.match(/[ACG]/gi) || []).length) / dnaTotal;
  var tMatch = ((dnaSeq.match(/[T]/gi) || []).length) / dnaTotal;
  var uMatch = ((dnaSeq.match(/[U]/gi) || []).length) / dnaTotal;

  var proteinSeq = seq.replace(/X/gi,'');
  var proteinTotal = proteinSeq.length;
  var proteinMatch = ((seq.match(/[ARNDCQEGHILKMFPSTWYV\*]/gi) || []).length) / proteinTotal;

  if (((acgMatch + tMatch) >= threshold) || ((acgMatch + uMatch) >= threshold)) {
    if (tMatch >= uMatch) {
      return 'dna';
    } else if (uMatch >= tMatch) {
      return 'rna';
    } else {
      return 'dna';
    }
  } else if (proteinMatch >= threshold) {
    return 'protein';
  }
};
