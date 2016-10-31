$(document).ready(function(){
    $('#login-form').validate();
    $('#token-form').validate();
    $('#signup-form').validate({
        rules : {
            password : {
                minlength : 5
            },
            password_confirmation : {
                minlength : 5,
                equalTo : "#password"
            }
        }
    });

    $('#login-form').submit(function(e) {
        e.preventDefault();
        if($('#login-form').valid() && !$('#login-btn').hasClass('disabled')){
            formData = $(e.currentTarget).serialize();
            $('#invalid-cred-error').addClass('compressed');
            attemptOneTouchVerification(formData);
        }
    })

    $('#token-form').submit(function(e) {
        e.preventDefault();
        if($('#token-form').valid() && !$('#submit-soft-token-btn').hasClass('disabled')){
            $('#invalid-token-error').addClass('compressed');
            submitSoftTokenForm();
        }
    })

    $('#signup-form').submit(function(e) {
        e.preventDefault();
        if($('#signup-form').valid() && !$('#signup-btn').hasClass('disabled')){
            formData = $(e.currentTarget).serialize();
            $('#invalid-cred-error').addClass('compressed');
            $('#error-during-signup-error').addClass('compressed');
            submitRegistrationForm(formData);
        }
    })

    $('#use-soft-token-btn').click(function(e){
        e.preventDefault();
        showSoftTokenForm();
    })

    var attemptOneTouchVerification = function(form) {
        $('#login-btn').addClass('loading').addClass('disabled');
        setTimeout(function(){
            $.post( "/login", form, function(data) {
                if(data.invalid_credentials){
                    $('#invalid-cred-error').removeClass('compressed');
                } else if(data.success) {
                    showOneTouchWrapper();
                    checkForOneTouch();
                } else {
                    $('.authy-softtoken-wrapper').fadeIn();
                }
                $('#login-btn').removeClass('loading').removeClass('disabled');
            })
        }, 1000)
    };

    var submitRegistrationForm = function(form) {
        $('#signup-btn').addClass('loading').addClass('disabled');
        setTimeout(function(){
            $.post( "/users", form, function(data) {
                if(data.duplicate_email){
                    $('#invalid-cred-error').removeClass('compressed');
                } else if(data.success) {
                    showSuccessRegistrationWrapper();
                } else {
                    $('#error-during-signup-error').removeClass('compressed');
                }
                $('#signup-btn').removeClass('loading').removeClass('disabled');
            })
        }, 1000)
    }

    var checkForOneTouch = function() {
        $.get( "/authy/status", function(data) {
            if (data == 'approved') {
                $('#request-approved-msg').removeClass('compressed');
                setTimeout(function(){
                    window.location.href = "/";
                }, 1000)
            } else if (data == 'denied') {
                showSoftTokenForm();
            } else {
                setTimeout(checkForOneTouch, 500);
            }
        })
    };

    var showSuccessRegistrationWrapper = function() {
        $('.signup-wrapper').fadeOut(function() {
            $('.success-registration-wrapper').fadeIn('slow')
        })
    };

    var showOneTouchWrapper = function() {
        $('.login-wrapper').fadeOut(function() {
            $('.authy-one-touch-wrapper').fadeIn('slow')
        })
    };

    var showSoftTokenForm = function() {
        $('.authy-one-touch-wrapper').fadeOut(function() {
            $('.authy-softtoken-wrapper').fadeIn('slow')
        })
    };

    var submitSoftTokenForm = function() {
        $('#submit-soft-token-btn').addClass('disabled').addClass('loading');
        setTimeout(function(){
            var tokenEntry = { token: $('#token_input').val() }
            $.post( "/authy/verify_soft_token", tokenEntry, function(data) {
                if (data.success) {
                    $('#token-verified-msg').removeClass('compressed');
                    setTimeout(function(){
                        window.location.href = "/";
                    }, 1000)
                } else {
                    $('#invalid-token-error').removeClass('compressed');
                    $('#submit-soft-token-btn').removeClass('disabled').removeClass('loading');
                }
            });
        }, 1000)
    }

})