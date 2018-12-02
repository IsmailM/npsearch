//= require dependencies/jquery
//= require dependencies/jquery.fine-uploader
//= require dependencies/jquery.validate
//= require dependencies/materialize
//= require dependencies/datatables
//= require dependencies/datatables-materialize
//= require dependencies/msa
//= require npsearch
//= require dependencies/turbolinks

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

if (Turbolinks.supported) {
  // show for any page that takes longer than 500 ms to load
  Turbolinks.setProgressBarDelay(200);
}

document.addEventListener("turbolinks:before-render", function (event) {
  FontAwesome.dom.i2svg({
    node: event.data.newBody
  });
});

document.addEventListener('turbolinks:before-cache', function () {
  M.Modal._count = 0;
  M.updateTextFields();
  //  Reset Datatables
  dataTable = $($.fn.dataTable.tables(true)).DataTable();
  if (dataTable != null) {
    dataTable.destroy();
  }
  dataTable = null;
  // reset FineUploader
  if (NS.fineUploader != null) {
    NS.fineUploader.reset()
    $('#fine-uploader-validation').empty();
  }
  NS.fineUploader = null;
});

//// FULL RELOAD WHEN JS ERROR

// If a JS error occurs in the browser, the app can be left in
// a bad state depending on how badly the JS console decides to crash.
// Subsequent errors can continue to be triggered because the page is
// never reloaded - so force a full page reload on the next page visit.
NS.jsErrorHasOccurred = false

window.onerror = function () {
  NS.jsErrorHasOccurred = true;
}

document.addEventListener("turbolinks:before-visit", function () {
  if (NS.jsErrorHasOccurred == true) {
    event.preventDefault(); // Cancel the turbolinks request
    window.location.href = event.data.url; // Do a regular page visit to clear the JS console
  }
});
