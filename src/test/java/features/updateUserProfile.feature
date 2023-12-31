@SmokeTest
Feature: Update user profile

  Background: 
    * def filePath = read(file_path)
    * def testDataFilePath = filePath.UserProfileTestData
    * def apiServerDataJson = read(apiServerData)
    * def baseURL = env == 'qa' ? apiServerDataJson.baseQaURL : apiServerDataJson.baseAnotherEnvURL
    * def getHeaderInfo = env == 'qa' ? filePath.Headers+'@qa' : filePath.Headers+'@env'
    * print getHeaderInfo
    * def setHeader = call read(getHeaderInfo)
    * print setHeader
    * configure headers = setHeader.HEADER

  #1.Creating new resource POST REQUEST
  Scenario Outline: Verify User able to update profile with valid data
    * def apiURI = apiServerDataJson["global-user-api(US)"].updateUserProfile
    * def endpoint = baseURL+apiURI
    Given url endpoint
    * def generateTestData = call read("file:"+filePath.GenerateTestData+'@updateUserProfile'){fileName:'#(testDataFilePath)', region: '<region>', index: '<index>', email: '#(email)', password:'#(password)'}
    * def request_body = read('file:'+filePath.UserProfileTestData)
    * print request_body
    And request request_body.<region>[<index>]
    When method PUT
    * print response
    # validate response status code
    Then status <status_code>
    And match response.metadata == { httpStatusCode: 200, requestId: '#string', attempts: '#number', totalRetryDelay: '#number' }
    And match response.updatedValues ==
      """
      {
      phone_number: '#string',
      last_name: '#string',
      first_name: '#string',
      timestamp: { updated_at: '#string' }
      }
      """
    And match response.updatedValues.phone_number == '#(request_body.<region>[<index>].phoneNumber)'
    And match response.updatedValues.last_name == '#(request_body.<region>[<index>].lastName)'
    And match response.updatedValues.first_name == '#(request_body.<region>[<index>].firstName)'

    @qa
    Examples: 
      | region | index | status_code |
      | qa     |     0 |         200 |
