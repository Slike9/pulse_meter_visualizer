require "spec_helper"

describe PulseMeter::Visualize::Widgets::Pie do
  let(:interval){ 100 }
  let!(:a_sensor){ PulseMeter::Sensor::Timelined::Counter.new(:a_sensor, :ttl => 1000, :interval => interval, annotation: 'A') }
  let!(:b_sensor){ PulseMeter::Sensor::Timelined::Counter.new(:b_sensor, :ttl => 1000, :interval => interval, annotation: 'B') }

  let(:widget_name){ "some_widget" }

  let(:redraw_interval){5}
  let(:values_label){'xxxx'}
  let(:width){6}
  let(:a_color){'#FF0000'}
  let(:b_color){'#FFFF00'}

  let(:interval_start){ Time.at((Time.now.to_i / interval) * interval) }

  let(:widget) do
    w = PulseMeter::Visualize::DSL::Widgets::Pie.new(widget_name)
    w.redraw_interval redraw_interval
    w.width width
    w.sensor :a_sensor, color: a_color
    w.sensor :b_sensor, color: b_color
    w.gchart_options a: 1
    w.to_data
  end

  describe "#data" do
    it "contains type, title, redraw_interval, width, gchart_options attriutes" do
      wdata = widget.data
      expect(wdata[:type]).to eq('pie')
      expect(wdata[:title]).to eq(widget_name)
      expect(wdata[:redraw_interval]).to eq(redraw_interval)
      expect(wdata[:width]).to eq(width)
      expect(wdata[:gchart_options]).to eq({a: 1})
    end

    describe "series attribute" do
      before(:each) do
        Timecop.freeze(interval_start + 1) do
          a_sensor.event(12)
          b_sensor.event(33)
        end
        Timecop.freeze(interval_start + interval + 1) do
          a_sensor.event(111)
        end
        @current_time = interval_start + 2 * interval - 1
      end

      it "contains valid pie slices" do

        Timecop.freeze(@current_time) do
          expect(widget.data[:series]).to eq(
            {
              data: [
                [a_sensor.annotation, 12],
                [b_sensor.annotation, 33]
              ],
              options: [
                {color: a_color},
                {color: b_color}
              ]
            }
          )
        end

      end

    end
  end
end



