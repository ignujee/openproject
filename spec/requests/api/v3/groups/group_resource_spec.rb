#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See docs/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'
require 'rack/test'

describe 'API v3 Group resource', type: :request, content_type: :json do
  include Rack::Test::Methods
  include API::V3::Utilities::PathHelper

  let(:project) { FactoryGirl.create(:project) }
  let(:group) do
    FactoryGirl.create(:group,
                       member_in_project: project,
                       member_through_role: role)
  end
  let(:group_project) { project }
  let(:role) { FactoryGirl.create(:role, permissions: permissions) }
  let(:permissions) { [:view_members] }
  let(:current_user) do
    FactoryGirl.create(:user,
                       member_in_project: project,
                       member_through_role: role)
  end

  subject(:response) { last_response }

  before do
    login_as(current_user)
  end

  describe '#get' do
    before do
      get get_path
    end

    context 'having the necessary permission' do
      let(:get_path) { api_v3_paths.group group.id }

      it 'responds with 200 OK' do
        expect(subject.status)
          .to eq(200)
      end

      it 'responds with a group resource' do
        expect(subject.body)
          .to be_json_eql('Group'.to_json)
          .at_path('_type')
      end

      it 'responds with the correct group' do
        expect(subject.body)
          .to be_json_eql(group.name.to_json)
          .at_path('name')
      end
    end

    context 'requesting nonexistent user' do
      let(:get_path) { api_v3_paths.group 9999 }

      it_behaves_like 'not found' do
        let(:id) { 9999 }
        let(:type) { 'Group' }
      end
    end

    context 'not having the necessary permission' do
      let(:permissions) { [] }
      let(:get_path) { api_v3_paths.group group.id }

      it_behaves_like 'not found' do
        let(:id) { group.id }
        let(:type) { 'Group' }
      end
    end
  end
end
