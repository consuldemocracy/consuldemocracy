App.Ckeditor = {
  initialize: function() {
    lang = $('.ckeditor').attr('ckeditor_lang')
    config = {language: lang,
              toolbar: ['bulletedList', 'numberedList', '|', 'heading',
                        '|', 'bold', 'italic', '|', 'link' ],
              heading: {
                options: [
                  { model: 'paragraph', title: 'Paragraph', class: 'ck-heading_paragraph' },
                  { model: 'heading1', view: 'h1', title: 'Heading 1', class: 'ck-heading_heading1' },
                  { model: 'heading2', view: 'h2', title: 'Heading 2', class: 'ck-heading_heading2' }
                ]
              }
             }
    ClassicEditor.create( document.querySelector( '.ckeditor' ), config )
      .then( editor => {
        window.editor = editor;
      } )
      .catch( err => {
        console.error( err.stack );
      } );
  }
};