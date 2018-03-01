namespace :step_nav do
  desc "Publish /learn-to-drive-a-car step navigation to publishing api"
  task publish_learn_to_drive_a_car: :environment do
    content_id = "e01e924b-9c7c-4c71-8241-66a575c2f61f"
    params = {
      base_path: "/learn-to-drive-a-car",
      publishing_app: "collections-publisher",
      rendering_app: "collections",
      public_updated_at: Time.zone.now.iso8601,
      update_type: "major",
      change_note: "updating the content to match the new step_by_step_nav schema",
      schema_name: "step_by_step_nav",
      document_type: "step_by_step_nav",
      title: "Learn to drive a car: step by step",
      description: "Learn to drive a car in the UK - get a provisional licence, take driving lessons, prepare for your theory test, book your practical test.",
      details: {
        step_by_step_nav: {
          title: "Learn to drive a car: step by step",
          introduction: [
            {
              content_type: "text/govspeak",
              content: "Check what you need to do to learn to drive."
            }
          ],
          steps: [
            {
              title: "Check you're allowed to drive",
              contents: [
                {
                  type: "paragraph",
                  text: "Most people can start learning to drive when they’re 17."
                },
                {
                  type: "list",
                  style: "required",
                  contents: [
                    {
                      href: "/vehicles-can-drive",
                      text: "Check what age you can drive"
                    },
                    {
                      href: "/legal-obligations-drivers-riders",
                      text: "Requirements for driving legally"
                    },
                    {
                      href: "/driving-eyesight-rules",
                      text: "Driving eyesight rules"
                    }
                  ]
                }
              ]
            },
            {
              title: "Get a provisional driving licence",
              contents: [
                {
                  type: "list",
                  style: "required",
                  contents: [
                    {
                      href: "/apply-first-provisional-driving-licence",
                      text: "Apply for your first provisional driving licence",
                      context: "£34"
                    }
                  ]
                }
              ]
            },
            {
              title: "Driving lessons and practice",
              contents: [
                {
                  type: "paragraph",
                  text: "You need a provisional driving licence to take lessons or practice."
                },
                {
                  type: "list",
                  style: "required",
                  contents: [
                    {
                      href: "/guidance/the-highway-code",
                      text: "The Highway Code"
                    },
                    {
                      href: "/driving-lessons-learning-to-drive",
                      text: "Taking driving lessons"
                    },
                    {
                      href: "/find-driving-schools-and-lessons",
                      text: "Find driving schools, lessons and instructors"
                    },
                    {
                      href: "/government/publications/car-show-me-tell-me-vehicle-safety-questions",
                      text: "Practise vehicle safety questions"
                    }
                  ]
                }
              ]
            },
            {
              title: "Prepare for your theory test",
              logic: "and",
              contents: [
                {
                  type: "list",
                  style: "required",
                  contents: [
                    {
                      href: "/theory-test/revision-and-practice",
                      text: "Theory test revision and practice"
                    },
                    {
                      href: "/take-practice-theory-test",
                      text: "Take a practice theory test"
                    },
                    {
                      href: "https://www.safedrivingforlife.info/shop/product/official-dvsa-theory-test-kit-app-app",
                      text: "Theory and hazard perception test app"
                    }
                  ]
                }
              ]
            },
            {
              title: "Book and manage your theory test",
              contents: [
                {
                  type: "paragraph",
                  text: "You need a provisional driving licence to book your theory test."
                },
                {
                  type: "list",
                  style: "required",
                  contents: [
                    {
                      href: "/book-theory-test",
                      text: "Book your theory test",
                      context: "£23"
                    },
                    {
                      href: "/theory-test/what-to-take",
                      text: "What to take to your test"
                    },
                    {
                      href: "/change-theory-test",
                      text: "Change your theory test appointment"
                    },
                    {
                      href: "/check-theory-test",
                      text: "Check your theory test appointment details"
                    },
                    {
                      href: "/cancel-theory-test",
                      text: "Cancel your theory test"
                    }
                  ]
                }
              ]
            },
            {
              title: "Book and manage your driving test",
              contents: [
                {
                  type: "paragraph",
                  text: "You must pass your theory test before you can book your driving test."
                },
                {
                  type: "list",
                  style: "required",
                  contents: [
                    {
                      href: "/book-driving-test",
                      text: "Book your driving test",
                      context: "£62"
                    },
                    {
                      href: "/driving-test/what-to-take",
                      text: "What to take to your test"
                    },
                    {
                      href: "/change-driving-test",
                      text: "Change your driving test appointment"
                    },
                    {
                      href: "/check-driving-test",
                      text: "Check your driving test appointment details"
                    },
                    {
                      href: "/cancel-driving-test",
                      text: "Cancel your driving test"
                    }
                  ]
                }
              ]
            },
            {
              title: "When you pass",
              contents: [
                {
                  type: "paragraph",
                  text: "You can start driving as soon as you pass your driving test."
                },
                {
                  type: "paragraph",
                  text: "You must have an insurance policy that allows you to drive without supervision."
                },
                {
                  type: "list",
                  style: "required",
                  contents: [
                    {
                      href: "/pass-plus",
                      text: "Find out about Pass Plus training courses"
                    }
                  ]
                }
              ]
            }
          ]
        }
      },
      locale: "en",
      routes: [
        {
          path: "/learn-to-drive-a-car",
          type: "exact"
        }
      ]
    }

    Services.publishing_api.put_content(content_id, params)
    Services.publishing_api.publish(content_id)
  end

  desc "Patch /learn-to-drive-a-car step links to publishing api"
  task patch_learn_to_drive_a_car_links: :environment do
    content_id = "e01e924b-9c7c-4c71-8241-66a575c2f61f"

    links = {
      links: {
        pages_part_of_step_nav: [
          'f725a60e-a666-4269-82b0-946ecfb84b7c', #/apply-first-provisional-driving-licence
          '4a97f073-a0cb-4217-85b8-1874f86066ea', #/apply-for-your-full-driving-licence
          'ef5c82d2-4b61-4e8d-963e-0cab01b5129d', #/automatic-driving-licence-to-manual
          '8d35443d-7bf1-4f51-b9b1-e398e1d44030', #/book-driving-test
          '9922b819-ffcb-4f38-888a-78b898d5e530', #/book-theory-test
          'ea2eb031-619f-4526-a4e4-319b422deb6f', #/cancel-driving-test
          '105bd06e-c43a-4ae4-9c89-1061990a0292', #/cancel-theory-test
          '42c61b61-8e13-40d2-88f4-e4e3d06c97fe', #/change-driving-test
          'fc051e5a-887f-4bd3-8843-39a6f6f34dfc', #/change-theory-test
          'e8158428-d702-40e3-8f5c-56b83f953c46', #/check-driving-test
          '7cf54b96-78d5-4250-9d8d-db5b09b7ac95', #/check-theory-test
          '19ce7e8f-d5cc-4c0f-a71c-f4aaf79f8732', #/complain-about-a-driving-instructor
          '57a1253c-68d3-4a93-bb47-b67b9b4f6b9a', #/driving-eyesight-rules
          'f9a72285-a72f-4bb0-a1d9-760680e49bfe', #/driving-lessons-learning-to-drive
                                                  #/driving-lessons-learning-to-drive/practising-with-family-or-friends
                                                  #/driving-lessons-learning-to-drive/taking-driving-lessons
                                                  #/driving-lessons-learning-to-drive/using-l-and-p-plates
          '93e88ff6-bcba-49c1-86bc-c3e3f6f32371', #/driving-licence-fees
          '3bf0efc2-476c-4a9a-bd8a-872fb5c8e4d0', #/driving-test
          'e31fe320-5f7b-467e-80f1-d87ac9e43224', #/driving-test-cost
          '3cb8e2ae-c92c-494b-908e-7365c53d067e', #/driving-test/changes-december-2017
                                                  #/driving-test/disability-health-condition-or-learning-difficulty
                                                  #/driving-test/driving-test-faults-result
                                                  #/driving-test/test-cancelled-bad-weather
                                                  #/driving-test/using-your-own-car
                                                  #/driving-test/what-happens-during-test
                                                  #/driving-test/what-to-take
          '421504cb-63c4-44fb-94ec-5d0129e1748c', #/dvlaforms
          '58355e33-7136-4e05-90ce-929f073a773c', #/find-driving-schools-and-lessons
          '8e91b028-d862-4972-9535-42a6b9fa2474', #/find-theory-test-pass-number
          '5e16bed2-7631-11e4-a3cb-005056011aef', #/government/publications/application-for-refunding-out-of-pocket-expenses
          '5f5f8b9b-7631-11e4-a3cb-005056011aef', #/government/publications/car-show-me-tell-me-vehicle-safety-questions
          '5f537378-7631-11e4-a3cb-005056011aef', #/government/publications/drivers-record-for-learner-drivers
          '68569e76-c291-4642-a159-f86681228320', #/government/publications/driving-instructor-grades-explained
          '5e16c201-7631-11e4-a3cb-005056011aef', #/government/publications/know-your-traffic-signs
          '5fdd25d5-7631-11e4-a3cb-005056011aef', #/government/publications/l-plate-size-rules
          '5d29a656-7631-11e4-a3cb-005056011aef', #/guidance/rules-for-observing-driving-tests
          'bbf6c11a-7dc6-4fe6-8dd8-68c09bdbe562', #/guidance/the-highway-code
          '2148f116-f909-4976-bb05-cb4899f3272a', #/legal-obligations-drivers-riders
          '2b422e36-85c4-40fb-a40b-5cd40c86c0f8', #/pass-plus
                                                  #/pass-plus/apply-for-a-pass-plus-certificate
                                                  #/pass-plus/booking-pass-plus
                                                  #/pass-plus/car-insurance-discounts
                                                  #/pass-plus/how-pass-plus-training-works
                                                  #/pass-plus/local-councils-offering-discounts
          '5562141a-1899-4382-ad41-b7aeaf7eb93c', #/report-an-illegal-driving-instructor
          'aefaa1cf-eed2-4c44-98bf-ab3a2ffbadd6', #/report-driving-test-impersonation
          '1788c387-8680-4454-8923-71ad0f632cbb', #/take-practice-theory-test
          'b5d8c773-3a31-45f2-838d-255afef5511a', #/theory-test
                                                  #/theory-test/hazard-perception-test
                                                  #/theory-test/if-you-have-safe-road-user-award
                                                  #/theory-test/multiple-choice-questions
                                                  #/theory-test/pass-mark-and-result
                                                  #/theory-test/reading-difficulty-disability-or-health-condition
                                                  #/theory-test/revision-and-practice
                                                  #/theory-test/what-to-take
          'd282adbd-33d9-4105-a895-0c1f888b0730', #/track-your-driving-licence-application
          'd6b1901d-b925-47c5-b1ca-1e52197097e2', #/vehicles-can-drive
        ]
      }
    }
    Services.publishing_api.patch_links(content_id, links)
  end
end
