/*
    NS - NpSearch's JavaScript module

    Define a global NS (acronym for NpSearch) object containing all
    NS associated methods:
*/

// define global NS object
var NS;
if (!NS) {
  NS = {};
}

NS.fasta = '>gi|328696568|ref|XP_003240064.1| PREDICTED: uncharacterized protein LOC100575472 [Acyrthosiphon pisum]\n' +
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

// NS module
(function () {
  // Creates a custom Validation for Jquery Validation plugin...
  // It ensures that sequences are either protein or DNA data...
  // If there are multiple sequences, ensures that they are of the same type
  // It utilises the NS.checkType function (further below)...
  NS.addSeqValidation = function () {
    $.validator.addMethod('checkInputType', function (value, element) {
      var types = [],
        type = '';
      if (value.charAt(0) === '>') {
        var seqs_array = value.split('>');
        for (var i = 1; i < seqs_array.length; i++) {
          var lines = seqs_array[i].split('\n');
          if (lines.length !== 0) {
            var clean_lines = jQuery.grep(lines, function (n) {
              return (n);
            });
            if (clean_lines.length !== 0) {
              clean_lines.shift();
              var seq = clean_lines.join('');
              type = NS.checkType(seq, 0.9);
              types.push(type);
              if ((type !== 'protein') && (type !== 'dna') && (type !== 'rna')) {
                return false;
              }
            }
          }
        }
        var firstType = types[0];
        for (var j = 0; j < types.length; j++) {
          if (types[j] !== firstType) {
            return false;
          }
        }
        return true;
      } else {
        type = NS.checkType(value, 0.9);
        if ((type !== 'protein') && (type !== 'dna') && (type !== 'rna')) {
          return false;
        } else {
          return true;
        }
      }
    }, '* The Input must be either DNA or protein sequence(s). Please ensure that your sequences do not contains any non-letter character(s). If there are multiple sequences, ensure that they are all of one type. ');
  };

  NS.setUpValidatorDefaults = function () {
    NS.addSeqValidation();
    $.validator.setDefaults({
      errorClass: 'invalid',
      errorPlacement: function (error, element) {
        error.insertAfter($(element).siblings('label'));
      }
    });
  };

  NS.initValidation = function () {
  if ($("#input").length == 0) return;
    NS.setUpValidatorDefaults();
    $('#input').validate({
      rules: {
        seq: {
          required: function (element) {
            return $('textarea[name=seq]').is(':visible');
          },
        },
        input_file: {
          required: function (element) {
            return $('textarea[name=input_file]').is(':visible');
          }
        }
      },

      submitHandler: function (form) {
        spinner_elem = document.getElementById("spinner_model");
        var spinner_modal = M.Modal.getInstance(spinner_elem);
        spinner_modal.open();

        // Check if some files are still running
        if (NS.fineUploader.getInProgress() !== 0) {
          $('.validation_text').text('Please wait until all the files have completely uploaded.');
          return false;
        }
        $('.validation_text').text('');

        var formData = $("#input").serializeArray();
        formData.push({
          name: "files",
          value: JSON.stringify(NS.fineUploader.getUploads())
        });

        $.ajax({
          type: 'POST',
          url: $('#input').attr('action'),
          data: formData,
          success: function (response) {
            NS.ajaxSuccessFunction(response);
          },
          error: function (e, status) {
            NS.ajaxErrorFunction(e, status);
          }
        })
      }
    });
  };

  // Sends the data within the form to the Server
  NS.ajaxSuccessFunction = function (response) {
    $('#results_box').show();
    $('#output').html(response);
    NS.initResultElem();
    $('html, body').animate({
      scrollTop: $('#results').offset().top
    });

    spinner_elem = document.getElementById("spinner_model");
    var spinner_modal = M.Modal.getInstance(spinner_elem);
    spinner_modal.close();
  };

  NS.initResultElem = function () {
    $('.alignment').css('max-width', $('.card').width() - 120 + 'px');
    $(window).on('resize', function () {
      $('.alignment').css('max-width', $('.card').width() - 120 + 'px');
    });

    var np_collapsible = document.querySelectorAll('.np_collapsible');
    M.Collapsible.init(np_collapsible);

    var np_inner_collapsible = document.querySelectorAll('.np_inner_collapsible');
    M.Collapsible.init(np_inner_collapsible, {
      onOpenStart: function (e) {
        var btn = e.getElementsByClassName("collapsible-header")[0];
        btn.innerHTML = 'View Less Information';
      },
      onCloseStart: function (e) {
        var btn = e.getElementsByClassName("collapsible-header")[0];
        btn.innerHTML = 'View More Information';
      }
    });
  };

  NS.ajaxErrorFunction = function (e, status) {
    $('#results_box').show();
    var errorMessage;
    if (e.status == 500 || e.status == 400) {
      errorMessage = e.responseText;
    } else {
      // errorMessage = e.responseText;=
      errorMessage = 'There seems to be an unidentified Error.';
    }
    $('#output').html(errorMessage);
    $('#spinnermodel').modal('close'); // remove progress notification
  };

  NS.initFineUploader = function () {
    if ($("#fine-uploader-validation").length == 0) return;
    if (NS.fineUploader != null) {
      NS.fineUploader.reset()
      $('#fine-uploader-validation').empty();
    }
    NS.fineUploader = new qq.FineUploader({
      element: $('#fine-uploader-validation')[0],
      template: 'qq-template-validation',
      request: {
        endpoint: '/api/upload'
      },
      thumbnails: {
        placeholders: {
          waitingPath: '/assets/img/fine-uploader/placeholders/file.png',
          notAvailablePath: '/assets/img/fine-uploader/placeholders/file.png'
        },
      },
      validation: {
        allowedExtensions: ['fa', 'fas', 'fna', 'faa', 'fasta'],
        itemLimit: 5,
        sizeLimit: 78650000 // 75MB
      },
      callbacks: {
        onSubmitted: function () {
          var elem = document.getElementById("input_type");
          var input_tabs = M.Tabs.getInstance(elem);
          if (input_tabs.index !== 1) {
            input_tabs.select('upload');
          }
        }
      },
      chunking: {
        enabled: true,
        concurrent: {
          enabled: true
        },
        success: {
          endpoint: "/api/upload_done"
        }
      }
    });
    NS.fineUploader.addExtraDropzone($(".drop_zone_container")[0]);
  };

  NS.initShowExampleButton = function () {
    if ($("#np_example").length == 0) return;
    if (NS.npexample_click !== true) {
      $(document).on('click', '#np_example', function () {
        $('#seq').focus();
        $('#seq_label').addClass('active');
        $('#seq').val(NS.fasta);
        $('#seq').valid();
        M.textareaAutoResize($('#seq'));
      });
      NS.npexample_click = true;
    }
  };

  NS.initSearchTabs = function () {
    var adv_params_collapsible = document.getElementById('adv_params_collapsible');
    if (adv_params_collapsible) {
      M.Collapsible.init(adv_params_collapsible, {
        onOpenStart: function (e) {
          var btn = e.getElementsByClassName("collapsible-header")[0];
          btn.innerHTML = 'Hide Advanced Parameters';
        },
        onCloseStart: function (e) {
          var btn = e.getElementsByClassName("collapsible-header")[0];
          btn.innerHTML = 'Show Advanced Parameters';
        }
      });
    }
    var tab_elem = document.getElementById("input_type")
    if (tab_elem) {
      M.Tabs.init(tab_elem, {
        onShow: function () {
          if ($(this)[0].index == 0) {
            $('.show_examples_text').show();
          } else {
            $('.show_examples_text').hide();
          }
        }
      });
    }
  };

  NS.initSearchModal = function () {
    M.Modal.init(document.getElementById("spinner_model"), {
      dismissible: false
    });
  };

  NS.initAdvancedParams = function () {
    $(document).on('change', '#all_hmm', function() {
      if ($('#all_hmm').is(':checked')){
        $('#default_hmms_options').hide()
        $('#custom_hmms_options').hide()
      } else {
        $('#default_hmms_options').show()
        $('#custom_hmms_options').show()
      }
    });
 };

  NS.initMaterialize = function () {
    $('.sidenav').sidenav();
    M.Modal.init(document.getElementById("login_modal"));
  };

  NS.initSpFilter = function () {
    $('.sp_filter').change(function () {
      if ($(this).prop('checked')) {
        $('.card').has('.no_sp_present').hide();
      } else {
        $('.card').has('.no_sp_present').show();
      }
    });
  };

  NS.addUserDropDown = function () {
    M.Dropdown.init(document.querySelectorAll('.dropdown-button'), {
      inDuration: 300,
      outDuration: 225,
      coverTrigger: false,
      hover: true,
      alignment: "right"
    });
  };

  NS.initNewHMMForm = function () {
    NS.setUpValidatorDefaults();
    $('#create_new_hmm').validate({
      rules: {
        seq: {
          required: function () {
            return $('textarea[name=seq]').is(':visible');
          },
        },
        input_file: {
          required: function () {
            return $('textarea[name=input_file]').is(':visible');
          }
        }
      },

      submitHandler: function () {
        spinner_elem = document.getElementById("spinner_model");
        var spinner_modal = M.Modal.getInstance(spinner_elem);
        spinner_modal.open();

        // Check if some files are still running
        if (NS.fineUploader.getInProgress() !== 0) {
          $('.validation_text').text('Please wait until all the files have completely uploaded.');
          return false;
        }
        $('.validation_text').text('');

        var formData = $("#create_new_hmm").serializeArray();
        formData.push({
          name: "files",
          value: JSON.stringify(NS.fineUploader.getUploads())
        });

        $.ajax({
          type: 'POST',
          url: $('#create_new_hmm').attr('action'),
          data: formData,
          success: function (response) {
            console.log(response);
            spinner_elem = document.getElementById("spinner_model");
            var spinner_modal = M.Modal.getInstance(spinner_elem);
            spinner_modal.close();
          },
          error: function (e, status) {
            NS.ajaxErrorFunction(e, status);
          }
        })
      }
    });
  }

  // FROM BIONODE-Seq - See https://github.com/bionode/bionode-seq
  // Checks whether a sequence is a protein or dna sequence...
  NS.checkType = function (sequence, threshold, length, index) {
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

    var dnaSeq = seq.replace(/N/gi, '');
    var dnaTotal = dnaSeq.length;
    var acgMatch = ((dnaSeq.match(/[ACG]/gi) || []).length) / dnaTotal;
    var tMatch = ((dnaSeq.match(/[T]/gi) || []).length) / dnaTotal;
    var uMatch = ((dnaSeq.match(/[U]/gi) || []).length) / dnaTotal;

    var proteinSeq = seq.replace(/X/gi, '');
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

  NS.initializeHmmTable = function (tableId, tableWrapperId) {
    $('#' + tableId).dataTable({
      bDestroy: true,
      "oLanguage": {
        "sStripClasses": "",
        "sSearch": "",
        "sSearchPlaceholder": "Enter Keywords Here",
        "sInfo": "_START_ -_END_ of _TOTAL_",
        "sLengthMenu": '<span>Rows per page:</span><select class="browser-default">' +
          '<option value="10">10</option>' +
          '<option value="20">20</option>' +
          '<option value="30">30</option>' +
          '<option value="40">40</option>' +
          '<option value="50">50</option>' +
          '<option value="-1">All</option>' +
          '</select></div>'
      },
    });
    if (NS[tableWrapperId + '_search'] !== true){
      $(document).on('click', '#' + tableWrapperId + ' .search-toggle', function () {
        if ($('#' + tableWrapperId + ' .hiddensearch').css('display') == 'none') {
          $('#' + tableWrapperId + ' .hiddensearch').slideDown();
        } else {
          $('#' + tableWrapperId + ' .hiddensearch').slideUp();
        }
      });
      NS[tableWrapperId + '_search'] = true
    }
  };

  NS.protocol = function () {
    if (NS.USING_SLL === "true") {
      return "https://";
    } else {
      return "http://";
    }
  };

  NS.addLoginOnClick = function () {
    $(document).on("click", '.login_button', function (e) {
      console.log('click')
      e.preventDefault();
      /** global: gapi */
      gapi.auth.authorize({
        immediate: false,
        response_type: 'code',
        cookie_policy: 'single_host_origin',
        client_id: NS.CLIENT_ID,
        scope: "email"
      }, function (response) {
        if (response && !response.error) {
          // google authentication succeed, now post data to server.
          jQuery.ajax({
            type: "POST",
            url: "/auth/google_oauth2/callback",
            data: response,
            success: function () {
              // TODO - just update the DOM instead of a redirect to self
              $(location).attr("href", window.location.href);
            }
          });
        } else {
          console.log("ERROR Response google authentication failed");
          // TODO: ERROR Response google authentication failed
        }
      });
    });
  };

  NS.saveGoogleFrame = function () {
    return NS.google_frame = $('iframe[id^="ssIFrame_google"]').detach();
  }

  NS.restoreGoogleFrame = function () {
    if ($('iframe[id^="ssIFrame_google"]').length > 0) {
      return $('iframe[id^="ssIFrame_google"]').replaceWith(NS.google_frame);
    } else {
      return $('body').append(NS.google_frame);
    }
  }

  NS.load_single_result = function () {
    var path = window.location.pathname
    if (!(path.startsWith('/result/') || path.startsWith('/sh/'))) return;
    spinner_elem = document.getElementById("spinner_model");
    M.Modal.init(spinner_elem, { dismissible: false });
    $('#spinner_model h2').text('Loading...');
    var spinner_modal = M.Modal.getInstance(spinner_elem);
    spinner_modal.open();
    $.ajax({
      type: 'POST',
      url: path,
      success: function (response) {
        NS.ajaxSuccessFunction(response);
      },
      error: function (e, status) {
        NS.ajaxErrorFunction(e, status);
      }
    });
  };

  NS.initAlignment = function (url, numSequences) {
    var seqs_length = parseInt(numSequences)
    if (seqs_length > 50) {
      max_height = 50 * 15;
    } else {
      max_height = seqs_length * 15;
    }
    var msa_alignment = msa({
      el: document.getElementById("msa"),
      importURL: url,
      zoomer: {
        alignmentHeight: max_height
      },
      vis: {
        conserv: true,
        seqlogo: true,
      }
    });
    msa_alignment.render();
  }
}());

window.gpAsyncInit = function () {
  if (NS.google_events_bound === true) return;
  gapi.auth.authorize({
    immediate: true,
    response_type: 'code',
    cookie_policy: 'single_host_origin',
    client_id: NS.CLIENT_ID,
    scope: 'email'
  });
  NS.addLoginOnClick();
  $(document).on('turbolinks:before-visit', NS.saveGoogleFrame)
             .on('turbolinks:render', NS.restoreGoogleFrame);
  NS.google_events_bound = true;
};
