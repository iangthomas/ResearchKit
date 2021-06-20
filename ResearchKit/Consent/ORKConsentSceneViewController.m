/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 Copyright (c) 2015, Ricardo Sánchez-Sáez.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKConsentSceneViewController.h"
#import "ORKConsentSceneViewController_Internal.h"

#import "ORKNavigationContainerView_Internal.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKTintedImageView.h"
#import "ORKStepView_Private.h"
#import "ORKStepContentView_Private.h"
#import "ORKConsentLearnMoreViewController.h"

#import "ORKConsentDocument_Internal.h"
#import "ORKConsentSection_Private.h"

#import "ORKHelpers_Internal.h"
#import "ORKSkin.h"


@interface ORKConsentSceneView ()

@property (nonatomic, strong) ORKConsentSection *consentSection;

@end

@implementation ORKConsentSceneView

- (void)setConsentSection:(ORKConsentSection *)consentSection {
    _consentSection = consentSection;
    
    // TODO: just a note these are Ian's changes to make the image not appear on smaller devices, so that the user does not need to scroll to see the next button.
    if ([[UIScreen mainScreen] bounds].size.height > 700) {
        self.stepTopContentImage = consentSection.image;
    } else {
        self.stepTopContentImage = nil;
    }
    self.stepText = [consentSection summary];
}

@end


static NSString *localizedLearnMoreForType(ORKConsentSectionType sectionType) {
    NSString *str = ORKLocalizedString(@"BUTTON_LEARN_MORE", nil);
    switch (sectionType) {
        case ORKConsentSectionTypeOverview:
            str = ORKLocalizedString(@"LEARN_MORE_WELCOME", nil);
            break;
        case ORKConsentSectionTypeDataGathering:
            str = ORKLocalizedString(@"LEARN_MORE_DATA_GATHERING", nil);
            break;
        case ORKConsentSectionTypePrivacy:
            str = ORKLocalizedString(@"LEARN_MORE_PRIVACY", nil);
            break;
        case ORKConsentSectionTypeDataUse:
            str = ORKLocalizedString(@"LEARN_MORE_DATA_USE", nil);
            break;
        case ORKConsentSectionTypeTimeCommitment:
            str = ORKLocalizedString(@"LEARN_MORE_TIME_COMMITMENT", nil);
            break;
        case ORKConsentSectionTypeStudySurvey:
            str = ORKLocalizedString(@"LEARN_MORE_STUDY_SURVEY", nil);
            break;
        case ORKConsentSectionTypeStudyTasks:
            str = ORKLocalizedString(@"LEARN_MORE_TASKS", nil);
            break;
        case ORKConsentSectionTypeWithdrawing:
            str = ORKLocalizedString(@"LEARN_MORE_WITHDRAWING", nil);
            break;
        case ORKConsentSectionTypeOnlyInDocument:
            assert(0); // assert and fall through to custom
        case ORKConsentSectionTypeCustom:
            break;
    }
    return str;
}


@implementation ORKConsentSceneViewController {
    ORKNavigationContainerView *_navigationFooterView;
    NSArray<NSLayoutConstraint *> *_constraints;
    
}

- (instancetype)initWithSection:(ORKConsentSection *)section {
    self = [super init];
    if (self) {
        _section = section;
        self.title = section.title;
        self.learnMoreButtonTitle = _section.customLearnMoreButtonTitle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _sceneView = [ORKConsentSceneView new];
    _sceneView.consentSection = _section;
    _sceneView.stepTitle = _section.title;
    [self.view addSubview:_sceneView];
    
    if (_section.content.length||_section.htmlContent.length || _section.contentURL) {
        ORK_Log_Info("%@", localizedLearnMoreForType(_section.type));
    }
    [self setupNavigationFooterView];
    [self setupConstraints];
}

- (void)setupNavigationFooterView {
    if (!_navigationFooterView) {
        _navigationFooterView = _sceneView.navigationFooterView ;
    }
    _navigationFooterView.continueButtonItem = _continueButtonItem;
    _navigationFooterView.continueEnabled = YES;
    [_navigationFooterView updateContinueAndSkipEnabled];
}

- (void)setupConstraints {
    if (_constraints) {
        [NSLayoutConstraint deactivateConstraints:_constraints];
    }
    _constraints = nil;
    _sceneView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _constraints = @[
                     [NSLayoutConstraint constraintWithItem:_sceneView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_sceneView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_sceneView
                                                  attribute:NSLayoutAttributeRight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:0.0],
                     [NSLayoutConstraint constraintWithItem:_sceneView
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0
                                                   constant:0.0]
                     ];
    [NSLayoutConstraint activateConstraints:_constraints];
}

- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    _continueButtonItem = continueButtonItem;
    _navigationFooterView.continueButtonItem = continueButtonItem;
}

- (void)setCancelButtonItem:(UIBarButtonItem *)cancelButtonItem {
    _cancelButtonItem = cancelButtonItem;
}

- (UIScrollView *)scrollView {
    return (UIScrollView *)self.view;
}

- (void)scrollToTopAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    ORKConsentSceneView *consentSceneView = (ORKConsentSceneView *)self.view;
    CGRect targetBounds = consentSceneView.bounds;
    targetBounds.origin.y = 0;
    if (animated) {
        [UIView animateWithDuration:ORKScrollToTopAnimationDuration animations:^{
            consentSceneView.bounds = targetBounds;
        } completion:completion];
    } else {
        consentSceneView.bounds = targetBounds;
        if (completion) {
            completion(YES);
        }
    }
}

#pragma mark - Action

- (IBAction)showContent:(id)sender {
    ORKConsentLearnMoreViewController *viewController = nil;
    
    if (_section.contentURL) {
        viewController = [[ORKConsentLearnMoreViewController alloc] initWithContentURL:_section.contentURL];
    } else {
        viewController = [[ORKConsentLearnMoreViewController alloc] initWithHTMLContent:((_section.htmlContent.length > 0) ? _section.htmlContent : _section.escapedContent)];
    }
    viewController.title = _section.title ?: ORKLocalizedString(@"CONSENT_LEARN_MORE_TITLE", nil);
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationOverFullScreen;
}

@end
