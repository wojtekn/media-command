@require-extension-exif
Feature: Fix WordPress attachments orientation

  Background:
    Given a WP install

  Scenario: Try to fix orientation for all images while none exists
    When I try `wp media fix-orientation`
    Then STDERR should be:
      """
      Error: No images found.
      """

  Scenario: Fix orientation for all images
    Given download:
      | path                             | url                                                                            |
      | {CACHE_DIR}/landscape-2.jpg      | https://raw.githubusercontent.com/thrijith/test-images/master/Landscape_2.jpg  |
      | {CACHE_DIR}/landscape-5.jpg      | https://raw.githubusercontent.com/thrijith/test-images/master/Landscape_5.jpg  |
      | {CACHE_DIR}/portrait-4.jpg       | https://raw.githubusercontent.com/thrijith/test-images/master/Portrait_4.jpg   |
      | {CACHE_DIR}/portrait-6.jpg       | https://raw.githubusercontent.com/thrijith/test-images/master/Portrait_6.jpg   |
    And I run `wp option update uploads_use_yearmonth_folders 0`

    When I run `wp media import {CACHE_DIR}/landscape-2.jpg --title="Landscape Two" --porcelain`
    Then save STDOUT as {LANDSCAPE_TWO}

    When I run `wp media import {CACHE_DIR}/landscape-5.jpg --title="Landscape Five" --porcelain`
    Then save STDOUT as {LANDSCAPE_FIVE}

    When I run `wp media import {CACHE_DIR}/portrait-4.jpg --title="Portrait Four" --porcelain`
    Then save STDOUT as {PORTRAIT_FOUR}

    When I run `wp media fix-orientation --dry-run`
    Then STDOUT should be:
    """
    1/3 "Portrait Four" (ID {PORTRAIT_FOUR}) will be affected.
    2/3 "Landscape Five" (ID {LANDSCAPE_FIVE}) will be affected.
    3/3 "Landscape Two" (ID {LANDSCAPE_TWO}) will be affected.
    Success: 3 of 3 images will be affected.
    """

    When I run `wp media fix-orientation`
    Then STDOUT should be:
    """
    1/3 Fixing orientation for "Portrait Four" (ID {PORTRAIT_FOUR}).
    2/3 Fixing orientation for "Landscape Five" (ID {LANDSCAPE_FIVE}).
    3/3 Fixing orientation for "Landscape Two" (ID {LANDSCAPE_TWO}).
    Success: Fixed 3 of 3 images.
    """

    # Verify orientation fix.
    When I run `wp media fix-orientation`
    Then STDOUT should be:
    """
    1/3 No orientation fix required for "Portrait Four" (ID {PORTRAIT_FOUR}).
    2/3 No orientation fix required for "Landscape Five" (ID {LANDSCAPE_FIVE}).
    3/3 No orientation fix required for "Landscape Two" (ID {LANDSCAPE_TWO}).
    Success: Images already fixed.
    """

  Scenario: Fix orientation for single image
    When I run `wp media import {CACHE_DIR}/portrait-6.jpg --title="Portrait Six" --porcelain`
    Then save STDOUT as {PORTRAIT_SIX}

    When I run `wp media fix-orientation {PORTRAIT_SIX}`
    Then STDOUT should be:
    """
    1/1 Fixing orientation for "Portrait Six" (ID {PORTRAIT_SIX}).
    Success: Fixed 1 of 1 images.
    """

    # Verify orientation fix.
    When I run `wp media fix-orientation {PORTRAIT_SIX}`
    Then STDOUT should be:
    """
    1/1 No orientation fix required for "Portrait Six" (ID {PORTRAIT_SIX}).
    Success: Image already fixed.
    """

  Scenario: Fix orientation for non existent image
    When I try `wp media fix-orientation 9999`
    Then STDERR should be:
    """
    Error: No images found.
    """
