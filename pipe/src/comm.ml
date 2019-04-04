open Unix
open String
(*first parent will write on pipe, which will be read by child. 
then child will modify the string and write back on pipe which 
will be read by the perent and printed on the screen *)

let comm = 
  let (fd_read_in1, fd_write_out1) = pipe() in       (*for parent to write and child to read*)
  let (fd_read_in2, fd_write_out2) = pipe() in       (*for child to write and parent to read*)
  let pid = fork() in
    match pid with 
    |0 -> close fd_write_out1;                       (*since child is going to read the msg 
                                                      from parent, close the write end of the 
                                                      descriptor*)
          let msg = Bytes.create 100 in
            ignore @@ read fd_read_in1 msg 0 100;
            close fd_read_in1;                        (*close the descriptor after reading the msg*)
            Printf.printf "%s\n" msg;

            let modified_msg = String.concat " " ["adding child msg in"; msg] in
              close fd_read_in2;                      (*since child is going to write the msg, 
                                                      close the correspondig read end of the descriptor*)
              ignore @@ write fd_write_out2 modified_msg 0 (length modified_msg);
              close fd_write_out2;                    (*close the descriptor once the msg is written*)
              exit 0                                  (*end the child process and return to parent*)

    |_ ->         (*parent will close the read end of the pipe and write through other end.
                  once written, that end will also be closed*)
        close fd_read_in1;
        let msg = "message from parent" in
          ignore @@ write fd_write_out1 msg 0 (length msg);
          close fd_write_out1;

          ignore @@ wait ;
                                                        
          close fd_write_out2;                         (*to read the response from the child, 
                                                        close the descriptor's write end, 
                                                        read the msg and then close the read end too*)
          
          let recvmsg = Bytes.create 100 in
          ignore @@ Unix.read fd_read_in2 recvmsg 0 100;
          close fd_read_in2;
          Printf.printf "%s\n" recvmsg;;



let () = comm;;