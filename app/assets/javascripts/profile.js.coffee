class @Profile
  constructor: (opts = {}) ->
    {
      @form = $('.edit-user')
    } = opts

    # Automatically submit the Preferences form when any of its radio buttons change
    $('.js-preferences-form').on 'change.preference', 'input[type=radio]', ->
      $(this).parents('form').submit()

    $('.update-username').on 'ajax:before', ->
      $('.loading-username').show()
      $(this).find('.update-success').hide()
      $(this).find('.update-failed').hide()

    $('.update-username').on 'ajax:complete', ->
      $('.loading-username').hide()
      $(this).find('.btn-save').enable()
      $(this).find('.loading-gif').hide()

    $('.update-notifications').on 'ajax:complete', ->
      $(this).find('.btn-save').enable()

    @bindEvents()

    @avatarGlCrop = $('.js-user-avatar-input').glCrop().data 'glcrop'

  bindEvents: ->
    @form.on 'submit', @onSubmitForm

  onSubmitForm: (e) =>
    e.preventDefault()
    @saveForm()

  saveForm: ->
    self = @

    formData = new FormData(@form[0])
    formData.append('user[avatar]', @avatarGlCrop.getBlob(), 'avatar.png')

    $.ajax
      url: @form.attr('action')
      type: @form.attr('method')
      data: formData
      dataType: "json"
      processData: false
      contentType: false
      success: (response) ->
        new Flash(response.message, 'notice')
      error: (jqXHR) ->
        new Flash(jqXHR.responseJSON.message, 'alert')
      complete: ->
        window.scrollTo 0, 0
        self.form.find(':input[disabled]').enable()

$ ->
  # Extract the SSH Key title from its comment
  $(document).on 'focusout.ssh_key', '#key_key', ->
    $title  = $('#key_title')
    comment = $(@).val().match(/^\S+ \S+ (.+)\n?$/)

    if comment && comment.length > 1 && $title.val() == ''
      $title.val(comment[1]).change()
