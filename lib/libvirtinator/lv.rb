namespace :lv do
  #desc "Remove a logical volume and recreate it."
  task :recreate => 'libvirtinator:load_settings' do
    on roles(:app) do
      as :root do
        if test "[", "-b", fetch(:data_disk_lv_path), "]"
          ask :yes_no, "Are you sure you want to delete and recreate the logical volume #{fetch(:data_disk_lv_path)}?"
          if fetch(:yes_no).chomp.downcase == "yes"
            execute "lvremove", "--force", fetch(:data_disk_lv_path)
            sleep 1
          end
        else
          warn "Error: #{fetch(:data_disk_lv_path)} not found, yet you called lv:recreate!"
        end
        Rake::Task["lv:create"].invoke
      end
    end
  end

  #desc "Create a logical volume."
  task :create => 'libvirtinator:load_settings' do
    on roles(:app) do
      as :root do
        if test "lvcreate", fetch(:data_disk_vg_path), "-L", "#{fetch(:data_disk_gb)}G", "-n", fetch(:data_disk_lv_name)
          Rake::Task["lv:mkfs"].invoke
        else
          fatal "Error running lvcreate!"
          exit
        end
      end
    end
  end

  #desc "Create an ext4 filesystem."
  task :mkfs => 'libvirtinator:load_settings' do
    on roles(:app) do
      as :root do
        unless test "[", "-b", fetch(:data_disk_lv_path), "]"
          raise "Tried to create filesystem but path does not exist!"
        end
        execute "mkfs.ext4", "-q", "-m", "0", fetch(:data_disk_lv_path)
      end
    end
  end
end

namespace :pg_lv do
  #desc "Remove a logical volume and recreate it."
  task :pg_recreate => 'libvirtinator:load_settings' do
    on roles(:app) do
      as :root do
        if test "[", "-b", fetch(:pg_data_disk_lv_path), "]"
          ask :yes_no, "Are you sure you want to delete and recreate the logical volume #{fetch(:pg_data_disk_lv_path)}?"
          if fetch(:yes_no).chomp.downcase == "yes"
            execute "lvremove", "--force", fetch(:pg_data_disk_lv_path)
            sleep 1
          end
        else
          warn "Error: #{fetch(:pg_data_disk_lv_path)} not found, yet you called pg:recreate!"
        end
        Rake::Task["pg_lv:pg_create"].invoke
      end
    end
  end

  #desc "Create a logical volume."
  task :pg_create => 'libvirtinator:load_settings' do
    on roles(:app) do
      as :root do
        if test "lvcreate", fetch(:pg_data_disk_vg_path), "-L", "#{fetch(:pg_data_disk_gb)}G", "-n", fetch(:pg_data_disk_lv_name)
          Rake::Task["pg_lv:pg_mkfs"].invoke
        else
          fatal "Error running lvcreate!"
          exit
        end
      end
    end
  end

  #desc "Create an ext4 filesystem."
  task :pg_mkfs => 'libvirtinator:load_settings' do
    on roles(:app) do
      as :root do
        unless test "[", "-b", fetch(:pg_data_disk_lv_path), "]"
          raise "Tried to create filesystem but path does not exist!"
        end
        execute "mkfs.ext4", "-q", "-m", "0", fetch(:pg_data_disk_lv_path)
      end
    end
  end
end
