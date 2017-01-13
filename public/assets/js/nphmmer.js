$(document).ready(function() {
  inputValidation();

  // Materialize set up
  $(".button-collapse").sideNav();
  $('.modal-trigger').leanModal();
  $('#input_type').click(function(){
    if ($('#upload').is(':visible')) {
      $('.show_examples_text').hide();
    } else {
      $('.show_examples_text').show();
    }
  });

  $('.more_info_btn').click(function(){
    var body = $(this).siblings('.more_info_body');
    if ($(body).is(':visible')) {
      $(this).text('View More Information');
    } else {
      $(this).text('View Less Information');
    }
  });

  $('.sp_filter').change(function() {
    if ($(this).prop('checked')) {
      $('.card').has('.no_sp_present').hide();
    } else {
      $('.card').has('.no_sp_present').show();
    }
  });
});

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

  var uploader = initUploader();

  addSeqValidation();
  var maxCharacters = $('#seq').attr('data-maxCharacters'); // returns a number or undefined
  $.validator.setDefaults({
    errorClass: 'invalid',
    errorPlacement: function(error, element) {
      error.insertAfter($(element).siblings('label'));
    }
  });

  $('#input').validate({
    rules: {
        seq: {
            required: true,
            minlength: 5,
            checkInputType: true,
            maxlength: maxCharacters // when undefined, maxlength is unlimited
        },
        input_file: {
          required: true
        }
    },
    messages: {
      seq: {
        maxlength: "The above input area supports up to a maximum of " + maxCharacters + " characters. Please use the File Upload feature if you wish to analyse more data."
      }
    },

    submitHandler: function(form) {
      $('#spinnermodel').openModal();

      if (uploader.getUploads().length === 0) {
          // No file to upload - call ajaxFunction.
          ajaxFunction();
      }
      else {
          // Upload file and automatically call ajaxFunction.
          uploader.uploadStoredFiles();
      }
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
      $('.alignment').css('max-width', $('.card').width() - 120 + 'px');
      $(window).on('resize', function(){
        $('.alignment').css('max-width', $('.card').width() - 120  + 'px');
      });

      $('.np_collapsible').collapsible();
      $('.np_inner_collapsible').collapsible();

      $('html, body').animate({
          scrollTop: $('#output').offset().top
      });

      $('#spinnermodel').closeModal(); // remove progress notification
    },
    error: function (e, status) {
      var errorMessage;
      if (e.status == 500 || e.status == 400) {
        errorMessage = e.responseText;
        $('#results_box').show();
        $('#output').html(errorMessage);
        $('#spinnermodel').closeModal(); // remove progress notification
      } else {
        errorMessage = e.responseText;
        $('#results_box').show();
        $('#output').html('There seems to be an unidentified Error.');
        $('#spinnermodel').closeModal(); // remove progress notification
      }
    }
  });
};

// Function is called each time the Adv. Params button is pressed...
var changeAdvParamsBtnText = function () {
  'use strict';
  var btn = document.getElementById('adv_params_btn');
  if (btn.innerHTML === '&nbsp;&nbsp;Show Advanced Parameters') {
    btn.innerHTML = '&nbsp;&nbsp;Hide Advanced Parameters';
  }
  else {
    btn.innerHTML = '&nbsp;&nbsp;Show Advanced Parameters';
  }
};

// Changes the input to an examplar dna or protein sequence...
var examplarSequences = function (){
  'use strict';
  var seqs = '>gi|328696568|ref|XP_003240064.1| PREDICTED: uncharacterized protein LOC100575472 [Acyrthosiphon pisum]\n' +
             'MTRLHSVIHKLPNWKQLRVVLKLMSIMGDPVASFPEIIELNKLRRWYEVRINENRHMTLKMKQNLMVQSINAWSAPRIKLTSVNVPQNPMPGEGKIGAMKITWNRVNEMKRKIKKTKSEYIDKLKRVAINNARTMYQTMYNDYYNSHLSRNFKQSYYDYFPAKEDDCLFEYVADRKNNK\n' +
             '>gi|641647015|ref|XP_008180670.1| PREDICTED: 33 kDa inner dynein arm light chain, axonemal-like [Acyrthosiphon pisum]\n' +
             'MSTVEKVLSSELNLVQFDNPKMIATKSMPTLSTQTKQEKYCMESNVSAMESGDYVDEAKQHNCTYVLNSILPRKEWEMDGKIFSQQISIQPATKRDVKNLVEKFDTYLKEYNTKVVGICPIKQEIYSQCFNEVIRQVTLNCTERGYMLIRIRDELQMTIDGYKEVYESALAHGIRKSLQAIL\n' +
             '>gi|328711854|ref|XP_003244660.1| PREDICTED: uncharacterized protein LOC100571180 [Acyrthosiphon pisum]\n' +
             'MVKIGLPWLLLVLMKLTNREIKSDEIISIQEVYDICQAEPNTDICDLLEKSSSLVDLNKLDSPEKRRQKTVFSSWGGKRQSTYPYGGKRPAFSSWGGKRASDKHGRPKQTFSSWGGKRSDYDGYDNGEMDEHQMDKRELNGIKQDKNNYRNKMTKGIHALFTIFSDWSRDPEEKKGIRYAGIKSMRRSSDFFPWGGKRFTGDAK\n' +
             '>gi|253735804|ref|NP_001156684.1| ecdysis triggering hormone preproprotein [Acyrthosiphon pisum]\n' +
             'MSGYLAIIVLVCLQILRVMSINEFPEKKVQNIWLADLDDKQIASRIERSDQFETASDVLMKDASVYPKITRRGFAGEEFFLKASKSVPRIGRRNNDIQETPKRSLSKDQVNMVEYWPYLQPNDINDLTRKHDFDLPYNCQQLDAKTIFLVDMYNFVCNDQFYCCAPAKRAIANSPNSNSL\n' +
             '>gi|328710353|ref|XP_003244236.1| PREDICTED: uncharacterized protein LOC100573178 [Acyrthosiphon pisum]\n' +
             'MTMSVTITILCILGSTFLLIMPDNTTASDKFFQTGGRFGKRHDEHIPDIRYAAMVKTRSVDNVPPRIERGFYISRYGKRSTNSITDPYYFTLCLPSYGIYCDFTGLPNLLRCKRIQPGACSNLNYVNEKTQMKPDNDIII\n' +
             '>gi|328721150|ref|XP_003247225.1| PREDICTED: uncharacterized protein LOC100571498 [Acyrthosiphon pisum]\n' +
             'MSFRKFFLRDNGKHRNMDSGGKNDESTTNKDEAKQGQHDAHKHHDIMGEIVLGQELPDNVKDNHNGVDLVDNQVKEVNPHSESLDTYQIDEYDDYMDEDINIITATLDI\n' +
             '>gi|193573549|ref|XP_001947462.1| PREDICTED: orcokinin peptides type A-like isoform X2 [Acyrthosiphon pisum]\n' +
             'MASSSTMIVAVASALCVHTILAYPTSIERVSGDNNYLPLRNSPSRDLDRFIEGENLLRDLEILRDRAEYFARQSRHINSLDGVGFGQSKRFDTLSGVSFGGQKRNFDEIDRSGFDRFVKKNFDEIDRSGFDRFVKKNFDEIDRSAFNSFVKRPNKVPAANLE\n' +
             '>gi|328711811|ref|XP_003244646.1| PREDICTED: uncharacterized protein LOC100163518 isoform X2 [Acyrthosiphon pisum]\n' +
             'MAGKFSALFLVGFVAAVVVAPYMMAEARYLPTRGNDDRLTRLKELLTDLLDSGAQPNLEMERPYVDVNGDFSRLRPREYNIPEKSIMELFNPTVPHHQRPRS\n' +
             '>gi|641677312|ref|XP_008187726.1| PREDICTED: uncharacterized protein LOC100569988 isoform X1 [Acyrthosiphon pisum]\n' +
             'MNPSILTLVWMSILVSLVQTVFADDVIMQKRYFDNDNPVAEPIRRKKPFCNAFTGCGRKRSDESMATLVDLRSEPAVEEISRQIMSEAKLWEAIQEARLELIRQQRQNKAERMDVKPYPIGLRRKRRSLATSDKC\n' +
             '>gi|328717573|ref|XP_003246245.1| PREDICTED: uncharacterized protein LOC100568735 [Acyrthosiphon pisum]\n' +
             'MPHKINVGLVALAALAAAVLADPSVDRRASMGFMGMRGKKDRDQGGGGSGGDETSAAVDLDKRTMVFRRPMFDGGSRPAVFGGGSAEGFKRASMGFMGMRGKKDYYSNNKGSAAGFFGMRGKKVPSADAFYGVRGKKWPDHEDAVDADVQLSPIYILYRIIDELKSELSDRERNLVAAKFDEEREMR\n' +
             '>gi|328721130|ref|XP_003247218.1| PREDICTED: alpha-tubulin N-acetyltransferase 1-like [Acyrthosiphon pisum]\n' +
             'MAMQFKFDSNSHVGQVLKINNTLTAEGYENNHELRNNLRLIIDEIGKSSAIAQHLEFPITSAQKLLNSDHVIYMMTEQNTPANFAVIGFLKMGWKKLFIYNKQDTCSETLVYCMLDFYIYESKQRQGYGKRLIEYMLQDMKLHARHLVMDKPTTNLLQFMLKNFQLSKLVNQGNNFAIYEDFFDEFNENHDYTGNRTSGYNRPPTFGRHGAHKHHDSMGEILQNTGPSSSVMHNHNNDFVHNQFHEVKPHTEEALGSLQINKYGDYVERDLKYHHSST\n' +
             '>gi|752421898|ref|XP_011230170.1| PREDICTED: glucagon [Ailuropoda melanoleuca]\n' +
             'MKSIYFVAGLFVMLVQGSWQRSLQDTEEKSRSLPAPQTDPLNDPDQMNEDKRHSQGTFTSDYSKYLDSRRAQDFVQWLMSTKRNKNNIAKRHDEFERHAEGTFTSDVSSYLEGQAAKEFIAWLVKGRGRRDFPEEVAIVEELRRRHADGSFSDEMNTVLDDLATRDFINWLLQTKITER\n' +
             '>gi|641675367|ref|XP_003247220.2| PREDICTED: alpha-tubulin N-acetyltransferase 1-like [Acyrthosiphon pisum]\n' +
             'MEFNFNIGKVATDEVLKINNTLTVEGHEENDDLKNIMRLIIDEMGKASAVSQEFKVPITSANRLVNSDHVIYMMTEHKKPGHFAVVGFLKMGWKKLFLYDKQASRSEARVYCLLDFYIHESKQRKGYGIRLIQCMLQDIGLEAKHLAIDKPTDKLLQFMWKHFQLSKLVNQENNFVIFEEFFHNSSEKKNNRDNTGNRAVAYKSQPMFGRHGAHKHHDSMAEIIQGEGNAAFVKFKYNQDTDFVDNQFKEKNPNPESKGAFKTNMDGYSVKRDLKFHHNSLW\n' +
             '>gi|641669265|ref|XP_008184748.1| PREDICTED: eukaryotic translation initiation factor 2-alpha kinase isoform X2 [Acyrthosiphon pisum]\n' +
             'MNLIIIKYLLKVVFIVFGVQTVFVLCDKPVCPGNHEANKQFIFISTLDGKLTALNTANGGTEAWKLSTEPGALLSSTIGQPELSNNGLWVRMIPSLSGSLYTFDGENLDRLPFTVDSLLKSYFPYYDGLAMSGGKISRTYGVDMSTGQLLYKCDMDQCNNFPSNSFTSIDGNILILQTQTQTVRASDTLTGIERWNFSVGLHDIKVIMDLNNNCHTTNPSIKLDFKINIPNGVVTAVAFDRPQEVVWTHKSESPIVNVWKFEHGKVESIDLFKPDHNLNSIDPVIYLGMHKKQLYIQENDKVFAVNPISYLKSLLLEGNEINKSRIPWKPIPVSSQLISKSPSALQTTDDVSKTTAIAVLYASEYINGNGFYLNGPQKTKRLIDGKKYKSFNSENENETENNHESIIQYEEGLEMPVEIIIVSLWYWWKEVLFISVITAILINIFIPSRLARIITFIHNRSKKNEGVEKIVEPIENNIDCCKDSGIEFSSDNIVQKQLHPIVEFKSRYLQDFEPIHCLGKGGFGIVFEARNKIDDCHYAIKRIPLPSKEESRNRVLREVKALAKLDHQHIVRYFNTWLEEPPSGWQEKHDDDWLQKSGDMDMNSNLTMSEKQVTNVCQNKHHVRAKSLSTWITLPESSEELSDILNNPHALRSYNDKSDSSFIVFESQISDTNTKDCILDISSDNLTKASKRRRYKSECDTTSNAHSERKATRHYLYIQMQLCHKNSLREWLKDNTKNRDMKYILNIFSQIIQAVEYVHLQGLIHRDLKLQK\n' +
             '>gi|193605856|ref|XP_001945771.1| PREDICTED: replication factor C subunit 2 [Acyrthosiphon pisum]\n' +
             'MEVDNPEEGASTSAVIDPMEGCSTSTNNVLTTVPPQTKTVKSDLNTPWIEKYRPKSFTDIVGNEETVLRLEKFSSCGNVPNIIIAGPPGVGKTTTILALARILLGGAFKEAVLELNASSDRGIDTVRNKIKMFAQQKVTLPPGRHKIIILDEADSMTDGAQQALRRTMELWSNTTRFALACNNSDKIIEAIQSRCAMLRYGKLSDQEVMTQMLKVCKSEEVSFSADGLEAVVFTAQGDMRQALNNLQSTWNGFRHVDSTNVFKVCDEPHPLLVKEMLLECADQNISKAYKIMAHLWKLGYAPEDIITNIFRVAKHLEIKESLKLKFVQEIGMAHIRIVEGMNSLLQLSGLLAKLCTVSAKTDG\n' +
             '>gi|193606041|ref|XP_001946815.1| PREDICTED: uncharacterized protein LOC100166012 [Acyrthosiphon pisum]\n' +
             'MQFNNYHDEAQKTDRDAPPPVEGRMDIGETSECKPRFGRHDAHKRHDTMGEIVQSGTDTMKFKYNHDNDFVDSRFKELIPHPEVVGELQTDKYGNSVKRDLKFHHSTLW\n' +
             '>gi|641675365|ref|XP_008187013.1| PREDICTED: uncharacterized protein LOC100166012 [Acyrthosiphon pisum]\n' +
             'MQFNNYHDEAQKTDRDAPPPVEGRMDIGETSECKPRFGRHDAHKRHDTMGEIVQSGTDTMKFKYNHDNDFVDSRFKELIPHPEVVGELQTDKYGNSVKRDLKFHHSTLW\n' +
             '>gi|193606039|ref|XP_001946532.1| PREDICTED: alpha-tubulin N-acetyltransferase 1-like [Acyrthosiphon pisum]\n' +
             'MEFKFDIKNVATEEVMKIDNTLTALGHEQNEDLKSIMKLIIDEMGKASAIAQELKMPITSGDKLANSDHILYMMTEHDKPEHFSVVGILKMGWKKLYLYNKEGLRSEAMVYCLLDFYIHESKQRKGYGKRLIECMLQDINLEAKHLAIDKPTKKLLQFMWKHYQLSKLVNQGNNFVIFEEFFDDALDEKNHDNSGHRAVSYMRQPMFGRHGAHKHHDTMGEIVQGEGDAAFVKFKYNQDTDFVDHQFKETNPHPENSNAFKTDKDGNSVKRDLKFHHNSLW\n' +
             '>gi|641675371|ref|XP_008187015.1| PREDICTED: poly(A) RNA polymerase, mitochondrial-like [Acyrthosiphon pisum]\n' +
             'MDLFKDWGLLCARILSDLELMNLSLTSTEIQSRVQQLCDSISSFQINTDSKKIHIFGSRIYGLATNTTDIDIYLEIDDTFDGIIANNEEIQVEYVQQFTKYCLLKPEVFQNVKSICNCRVPIVTFYHVPSKFICDVSFKSGLGTYNTKLIKFYLSMDTTVKWLVCVIVKNWALQNGLKDRNLFTSYALIWLVLFYLMTEKVVPSLIKLRQNATKADHKVIEGWDCTFGKCSVYISEDKRPKLLMGFFQYYANKRALKDNVLSTCTGQLIKKHAFYEKFSQLPGLSKIQRTKFKNFKAKVDSSFEKNYGLVLQDPFELSFNLTRNLHNQALTDFCDLCHQSSTLLINMKGYSMFSNT\n' +
             '>gi|641676236|ref|XP_008187335.1| PREDICTED: allatostatins [Acyrthosiphon pisum]\n' +
             'MHHSCCMWILVIATAVWTDAITGHEDKVGIKSQQAQQQQQSDIMQTMVDGGGHQSIQMTSPAESYFNDPLGPLGYLAKRAHKQYGFGLGKRLYRQYEFGLGKRSASKQYGFGLGKRAALKQYEFGLGKRASPTFYSFGLGRRASPQYSFGLGKRVSHPSFLNVDDRESDYTYNDLSEEKKRTADDMGHGQRFAFGLGKRGAGAEWDDGDGDGDDAAPIWHPAVRRARLQYGFGLGKRADRDYDATTGTEYTDTLQLADDAADINN\n' +
             '>gi|641675388|ref|XP_008187022.1| PREDICTED: uncharacterized protein LOC103310453 [Acyrthosiphon pisum]\n' +
             'MAEIMNIDVSIKLPPLLLQSFSINNYEAKCMKCNISCAPEEEDILFHLSVCNGTLIEENIQTLFKFNCLECNYLTHSIDQWKCHLFKLDHISKSFDFDILRLSYDCKSCNTHFFGFRDSILKHHCKPQFIPSISYLMSSVYKNYNVQDEQTMFHYCTDCSFFTDNLTELHKKEHSEVADPSVCHSCLITFYGSSNEEFLNHKVSFEHILLWCLNGARSVPKMSTTAFQNLPYYITKYFVISPLLKKFCCIVCNTKNILTYECIYDHFYNCISSKEISDVKGCNPLLSINCNLCDYSCFSVDDMYKCWVDHVISFDHLSKTVILSLKI\n' +
             '>gi|641675373|ref|XP_008187016.1| PREDICTED: poly(A) RNA polymerase, mitochondrial-like [Acyrthosiphon pisum]\n' +
             'MNLSRTSIETRSRVQQLCDSICSFQINTDSKKIHTFGSRVYGLATNTTNIDIYLEIDDTFDGIIANNEKIQVEYVQQFTKYCLSKPEVFQNVKSICNCRMPIVTFYHVPSKFICDVSFKSGLVTYNTELIKFYLLMNPTVKWLVCVIVKNWAPQNGLIDRQLFTSYALIWLVLFYLMTEKVVPSLIKLRHISTEDDHKVIEGWDCTFGKCFIYISEEKRPKLLLGFFQYYANKRALKDNVLSTCTGQLIKKHEFFERFSQLPGLSQIQRTKFKNFKAEVDSSFEKNYGLVLQDPFELSFNLTRNLHDKALNDFCDLCMQSSRLLLNMKD\n' +
             '>gi|641659926|ref|XP_008181304.1| PREDICTED: uncharacterized protein LOC100570556 isoform X2 [Acyrthosiphon pisum]\n' +
             'MHKFFVQIYIFVLIIWAVEKSDCKQGACLNYGHSCWGAHGKRNVPNDLDSLIRYRMAVFKKSGHRDSFINPNADQSQEDIPNYYNIFKHYSKINSVKTNNDDTVDTWSLEPSNNLPSGGSYYEDQVLDPRIEYKIMKI\n' +
             '>gi|301771746|ref|XP_002921293.1| PREDICTED: thyrotropin releasing hormone [Ailuropoda melanoleuca]\n' +
             'MPGPWLQLAMALTLTVAGIPGGRAQPEVAQQEAAMAPERAGLDDLLRQAQRLLFLREDLQRLRGNQGDLESEAQILQPDWLSKRQHPGKREGEAEEGVEEEEEEGGAVGPHKRQHPGRQEDVAAWSDVTLQKRQHPGRRAPLLGYAFTKRQHPGRRLVDSKAQRSWEAEEEDGEEEGGEPMPEKRQHPGKRALGSPCGPGAACGQASLLLGLLDDLSRGQGAEEKRQHPGRRAAWAREPLEE\n' +
             '>gi|193629757|ref|XP_001950852.1| PREDICTED: splicing factor U2AF 50 kDa subunit-like [Acyrthosiphon pisum]\n' +
             'MGEDKERERDRDRGEREKERGERRRRSRSRDRERHRRHRSRSRDGRKRSRSKSPKNKSRRRKPSLYWDVPPPGFEHIAPLQYKAMQAAGQIPANTMPDTPQTAVPVVGSTITRQARRLYVGNIPFGVTEDEMMEFFNQQMHLSGLAQAAGNPVLACQINLDKNFAFLEFRSIDETTQAMAFDGINFKGQSLKIRRPHDYQPTPGMTESNPVTNYNSGMTLDMMKYDSSSFGLGTVPDSPHKIFIGGLPAYLNDEQVKELLTSFGQLKAFNLVKDAATGLSKGYAFCEYADVVMTDQAIAGLNGMQLGEKKLIVQRASIGAKNPGLGQAPVTIQVPGLTVVGTAGPPTEVLCLLNMVTPDELKDEEEYEDILEDIREECNKYGVVRSLEIPRPIEGIDVPGCGKVFIEFNAIPDCQKAQQALAGRKFNNRVVVTSFMEPDKYHRREF\n';
  $('#seq').focus();
  $('#seq_label').addClass('active');
  $('#seq').val(seqs);
  $('#seq').valid();
  $('#seq').trigger('autoresize');
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

/**
 * Initialise fine-uploader file uploader in basic mode.
 */
var initUploader = function () {
  return new qq.FineUploaderBasic({
    // When triggered, upload to this URL. Don't auto upload: we will
    // upload manually.
    request: { endpoint: '/upload' }, autoUpload: false,

    button: document.getElementById('qq-file-btn'),

    validation: {
      allowedExtensions: ['fa','fas','fna','faa','fasta'],
      sizeLimit: 78650000 // 75MB
    },

    multiple: false,

    callbacks: {
      // Update input.file-path when a file is selected.
      onSubmit: function (id, name) {
        $('#qq-filename').attr('value', name);
      },

      // Submit form after file has been uploaded.
      onComplete: function (id, name, responseJson, xhr) {
        $('#qq-uuid').val(this.getUuid(id));
        ajaxFunction();
      },
      
      // show an error message if required.
      onError: function(id, name, errorReason, xhrOrXdr) {
        $('.file-field').append('<label id="file_error" class="invalid">* ' + errorReason + '</label>');
      },

      // remove any existing file error message just before validating
      onValidate: function() {
        $('#file_error').remove();
      }
    },

    // Set the default method of displaying error messages
    showMessage: function(message) {
      $('.file-field').append('<label id="seq-error" class="invalid" for="seq">* ' + message + '</label>');
    },

    // Chunk the data and allow concurrency
    chunking: {
      enabled: true,
      concurrent: {
          enabled: true
      },
      success: {
        endpoint: "/uploaddone"
      }
    }
  });
};
