require 'test_helper'

class PublicationListingsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get publication_listings_new_url
    assert_response :success
  end

  test "should get create" do
    get publication_listings_create_url
    assert_response :success
  end

  test "should get update" do
    get publication_listings_update_url
    assert_response :success
  end

  test "should get edit" do
    get publication_listings_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get publication_listings_destroy_url
    assert_response :success
  end

  test "should get index" do
    get publication_listings_index_url
    assert_response :success
  end

  test "should get show" do
    get publication_listings_show_url
    assert_response :success
  end

end
